#!/bin/bash
#  do_replication.sh
#  Single-file replication driver for
#  "Unemployment Benefits and Unemployment in the Great Recession:
#   The Role of Macro Effects" (Hagedorn, Karahan, Manovskii, Mitman), JPE.
#
#  Runs the ENTIRE pipeline from the shipped raw/provided data to the compiled
#  paper: from-raw input rebuild -> master datasets -> factor-model exporters ->
#  MATLAB interactive-fixed-effects estimations + block bootstraps -> imputation
#  -> structural model -> final Stata analyses -> figures -> tables -> PDF.
#
#  PREREQUISITES (see README.md section 3):
#    - Stata/MP   ("stata-mp" on PATH, or set STATA=/path/to/stata-mp).
#                  config.do auto-installs the required SSC packages on first run.
#    - MATLAB     ("matlab" on PATH, or set MATLAB=/path/to/matlab). R2025b tested.
#    - python3    (standard library only) for the table assembler; a python3 with
#                  geopandas+matplotlib for the two map figures (set PYTHON_GEO,
#                  e.g. PYTHON_GEO="conda run -n myenv python3"; skipped if absent).
#    - TeX        (pdflatex + bibtex on PATH) to compile the paper.
#
#  BEFORE RUNNING: edit the `root` path once in code/config.do and once in
#  code/matlab/config.m (see README.md section 5). Run this script from the
#  archive root:   bash do_replication.sh
#
#  RUNTIME: roughly 10-15 hours sequentially on a multi-core machine. The heavy
#  steps are the from-raw input rebuild (~1.5h), the ~30 factor-model front-ends
#  with 200-rep cluster bootstraps (~5-15 min each), the 200-pairing Scrambles
#  runs (~1-2h), the Monte Carlo, and the structural model.
#
#  NOTE on the vacancy data: the kit runs on the public synthetic stand-in for
#  the proprietary HWOL vacancy series (see README.md section 6), so the
#  vacancy-dependent exhibits are demonstrative; everything else is exact.
# ---------------------------------------------------------------------------
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
CODE="$ROOT/code"
STATA="${STATA:-$(command -v stata-mp || echo /Applications/StataNow/StataMP.app/Contents/MacOS/stata-mp)}"
MATLAB="${MATLAB:-$(command -v matlab || echo /Applications/MATLAB_R2025b.app/bin/matlab)}"
PYTHON_GEO="${PYTHON_GEO:-python3}"
LOGDIR="$ROOT/output/logs"
mkdir -p "$LOGDIR" "$ROOT/output/tables" "$ROOT/output/figures" \
         "$ROOT/output/factor_results" "$ROOT/output/factor_inputs" "$ROOT/data/processed"

say () { printf '\n[%s] ==== %s ====\n' "$(date '+%H:%M:%S')" "$*"; }

# --- fail fast if the one required path edit has not been made -------------
# code/config.do and code/matlab/config.m must point `root` at THIS archive;
# otherwise the pipeline dies deep inside step (2) with an unhelpful error (or
# writes into an unrelated tree). See README "Instructions to replicators".
STATA_ROOT=$(sed -n 's/^global root "\(.*\)".*/\1/p' "$CODE/config.do" | head -1)
STATA_ROOT="${STATA_ROOT/#\~/$HOME}"
if [ "$(cd "$STATA_ROOT" 2>/dev/null && pwd)" != "$ROOT" ]; then
    echo "ERROR: the 'global root' line in code/config.do points to '$STATA_ROOT'," >&2
    echo "       not to this archive ($ROOT). Edit code/config.do (and code/matlab/config.m)" >&2
    echo "       as described in README 'Instructions to replicators', then re-run." >&2
    exit 1
fi
if grep -q "'Dropbox','UI_ReplicationKit'" "$CODE/matlab/config.m" \
   && [ "$ROOT" != "$HOME/Dropbox/UI_ReplicationKit" ]; then
    echo "ERROR: code/matlab/config.m still has the default 'root' path. Edit its root line" >&2
    echo "       to point at this archive ($ROOT), then re-run." >&2
    exit 1
fi

# Stata batch mode ALWAYS exits 0; a do-file failure leaves an r(###) line in
# the log, so every Stata step is checked for that instead.
run_stata () {              # run_stata <script-path-relative-to-code/>
    local script="$1"
    local logname; logname="$(basename "${script%.do}").log"
    say "Stata: $script"
    ( cd "$CODE" && "$STATA" -e do "$script" )
    if grep -qE '^r\([0-9]+\)' "$CODE/$logname"; then
        echo "FAILED: $script -- first error context:" >&2
        grep -B 12 -m 1 -E '^r\([0-9]+\)' "$CODE/$logname" >&2
        exit 1
    fi
    mv -f "$CODE/$logname" "$LOGDIR/$logname"
}

run_matlab () {             # run_matlab <dir-under-code/> <script-name-without-.m>
    say "MATLAB: $2"
    # run('<file>.m') rather than a bare name: required for scripts whose names
    # start with a digit (step1_backoutf_fp), equivalent for all the others
    ( cd "$CODE/$1" && "$MATLAB" -batch "run('$2.m')" ) || { echo "FAILED: MATLAB $2" >&2; exit 1; }
}

# ============================================================================
# (1) MATLAB pre-step of the data build: back out county job-finding rates
#     from the continuing-claims records (Stata cannot call MATLAB, so the
#     orchestrator RunBuild.do expects this to have run first; the shipped
#     jobfindingfp intermediate makes it idempotent).
# ============================================================================
run_matlab build/RawDataScripts/JobFinding step1_backoutf_fp

# ============================================================================
# (2) Data build: Stage 1 rebuilds every from-raw input in data/raw/ from the
#     shipped primary sources, Stage 2 builds the three master datasets in
#     data/processed/. (Stage 1 is controlled by `rebuild_from_raw' inside
#     code/RunBuild.do; it ships enabled for a full from-primary replication.)
# ============================================================================
run_stata RunBuild.do

# ============================================================================
# (3) Factor-model exporters: write the per-pair QBLS text files for every
#     experiment into output/factor_inputs/.
# ============================================================================
for e in Bench Uhlig CBSA Controls DiscFactor Dist30 Distance \
         EmpQCEW EmpQCEW_Beg EmpShare HWOL HWOL_Beg Industry JFR \
         Placebo QDK QWIW QWIWStayers Scrambles; do
    run_stata "exporters/OutputDataSetsUIMacro_$e.do"
done

# ============================================================================
# (4) MATLAB factor-model front-ends: interactive-fixed-effects estimation +
#     200-rep cluster block bootstrap per experiment; results land as CSVs in
#     output/factor_results/. ProcessQDK aggregates the QDK horizons
#     (Forward_Spec); RunMonteCarlo runs the estimator Monte Carlo on the
#     shipped baseline panel (code/matlab/kit_mc_baseline.mat).
# ============================================================================
for f in Bench BenchBeg Additivity EarlyRec Uhlig CBSA CBSABeg \
         Controls ControlsBeg ControlsOnebyOne ControlsLevOnebyOne \
         DiscFactor Dist30 Dist30Beg Distance EmpQCEW EmpQCEW_Beg \
         EmpShare EmpShareBeg HWOL HWOL_Beg Industry IndustryBeg JFR \
         Placebo Placebo2001 QDK QWIW QWIWStayers Scrambles ScramblesBeg; do
    run_matlab matlab "Factor_FrontEnd_$f"
done
run_matlab matlab ProcessQDK
run_matlab matlab RunMonteCarlo
run_matlab matlab Fig_InitialGuess     # Figure A-3 (initial_guess.pdf, from the shipped baseline panel)

# ============================================================================
# (5) LAUS imputation chain (Stata -> MATLAB -> Stata) and its results table.
# ============================================================================
run_stata analysis/Impute_Input.do
run_matlab matlab Run_Impute_Border
run_stata analysis/Impute_to_Stata.do
run_stata analysis/Imputed_Results.do

# ============================================================================
# (6) Structural model: calibration + permanent-effect validation, then the
#     model-simulated panel regression.
# ============================================================================
run_matlab model RunModel
run_matlab model Fig_StateU            # Figure A-4 (StateUCrop.pdf, from the simulated panel)
run_stata analysis/ModelPanelRegression.do

# ============================================================================
# (7) Final Stata analyses: OLS tables, endogeneity tests, robustness checks,
#     Missouri study, mobility, figures.
# ============================================================================
for a in Table1_OLS Table1_OLS_Controls TableA2 Endog_Vars Endog_Bartik \
         Endog_Bartik_Scrambles Check_UFU Derived_Policy_Calcs \
         Bias_Sim_Shares Mobility_LODES Binscatter_Figures \
         MO_Tightness_Figures; do
    run_stata "analysis/$a.do"
done

# ============================================================================
# (8) Map figures (python + geopandas; skipped with a warning if the
#     environment lacks geopandas -- the maps are the only consumers).
# ============================================================================
if $PYTHON_GEO -c "import geopandas, matplotlib" 2>/dev/null; then
    say "python maps"
    ( cd "$CODE" && $PYTHON_GEO analysis/Make_BenefitMaps.py && $PYTHON_GEO analysis/Make_CountyMap.py ) \
        || { echo "FAILED: map figures" >&2; exit 1; }
else
    echo "WARNING: no python with geopandas found (set PYTHON_GEO); skipping the two map figures." >&2
fi

# ============================================================================
# (9) Assemble the paper tables and compile the PDF.
# ============================================================================
say "make_tables.py"
( cd "$CODE/tex" && python3 make_tables.py ) || { echo "FAILED: make_tables.py" >&2; exit 1; }

say "pdflatex"
# NOTE: pdflatex in nonstopmode exits non-zero on ANY recoverable error, and
# bibtex exits 1 on mere warnings, so the passes are not &&-gated on exit
# status. Real failure is detected from the artifact itself: no/empty PDF or a
# fatal error in the .log.
( cd "$CODE/tex" && {
    rm -f MacroElasticity_JPE_Rev3_1_I.{aux,log,bbl,blg,out,pdf}   # judge only a fresh build
    pdflatex -interaction=nonstopmode MacroElasticity_JPE_Rev3_1_I.tex > /dev/null
    bibtex   MacroElasticity_JPE_Rev3_1_I > /dev/null
    pdflatex -interaction=nonstopmode MacroElasticity_JPE_Rev3_1_I.tex > /dev/null
    pdflatex -interaction=nonstopmode MacroElasticity_JPE_Rev3_1_I.tex > /dev/null
  } )
if [ ! -s "$CODE/tex/MacroElasticity_JPE_Rev3_1_I.pdf" ] \
   || grep -q 'Fatal error occurred' "$CODE/tex/MacroElasticity_JPE_Rev3_1_I.log"; then
    echo "FAILED: paper compile" >&2; exit 1
fi
# surface (but do not fail on) missing figures/tables and unresolved references
grep -E 'LaTeX Warning: (File|Reference|Citation).*(not found|undefined)|^! ' \
    "$CODE/tex/MacroElasticity_JPE_Rev3_1_I.log" >&2 || true
cp "$CODE/tex/MacroElasticity_JPE_Rev3_1_I.pdf" "$ROOT/output/"

# Emit a self-contained .tex alongside the PDF. The shipped manuscript is a
# skeleton: every reproduced number enters via \input{} of an output/tables/
# file, and the reference list via bibtex, so the PDF is the only artifact that
# carries the run's results. Flattening those back into one .tex makes the
# results diffable against the shipped source. Must run BEFORE the cleanup
# below, which deletes the .bbl.
say "flatten_tex.py"
( cd "$CODE/tex" && python3 flatten_tex.py \
      MacroElasticity_JPE_Rev3_1_I.tex \
      "$ROOT/output/MacroElasticity_JPE_Rev3_1_I.flat.tex" \
      "$ROOT/output/tables" "$ROOT/output/figures" ) \
    || { echo "FAILED: flatten_tex.py" >&2; exit 1; }

( cd "$CODE/tex" && rm -f MacroElasticity_JPE_Rev3_1_I.{aux,log,bbl,blg,out} )

say "REPLICATION COMPLETE -- paper at output/MacroElasticity_JPE_Rev3_1_I.pdf (flattened source: output/MacroElasticity_JPE_Rev3_1_I.flat.tex), tables in output/tables/, figures in output/figures/"
