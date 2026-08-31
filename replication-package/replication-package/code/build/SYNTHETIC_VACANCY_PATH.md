# Synthetic-vacancy path (running the kit without the proprietary HWOL data)

The vacancy/tightness results use The Conference Board's **Help-Wanted OnLine (HWOL)**
county vacancy counts, which are **proprietary and cannot be redistributed**. This kit
ships a **public-data synthetic stand-in** so the entire pipeline runs end-to-end and is
auditable without a HWOL licence.

> **⚠ Demonstrative, not a reproduction.** The synthetic vacancies give realistic levels
> and cross-county/time structure (validated against real HWOL: log-vacancy corr ≈ 0.87,
> log-tightness ≈ 0.42), so the vacancy-gated tables/figures *run* and come out *sensible*
> and sign-consistent. They do **not** reproduce the published point estimates — those
> require the licensed HWOL data. Everything not vacancy-gated (e.g. the QCEW employment
> column, all unemployment results) is exact and fully shippable.

## The one proprietary input
HWOL enters in exactly two places (both replaced):

| real (proprietary) | feeds | synthetic replacement |
|---|---|---|
| `new_vac_april2017.dta` (county `total_vacancies_county` / `total_newvacancies_county`) | build's `vacrate1`/`tight1`; the JC table; imputation | `new_vac_synthetic.dta` |
| `total_vacancies_state` in `StateMonthlyBorderData_2018_07_25.dta` | Missouri tightness figures + `tab:MO_V_U` | `StateMonthlyBorderData_synthetic.dta` (public state cols + summed synthetic county vacancies) |

(There is no third HWOL input. `bartik_hinter` is QWI-derived and is not used.)

## The synthetic generator
`Make_Synthetic_Vacancies.do` builds `new_vac_synthetic.dta` from public data only:
a Beveridge model `vacrate_ct = openings_rate_y · exp(−β·(u_ct − ū_t) + ε_ct)` with the
national **JOLTS** job-openings rate (level + recession profile), county **LAUS**
unemployment (cross-sectional/time variation), and a **seeded** persistent county
deviation + transitory noise (dispersion & persistence). Calibration constants are
documented in the script; the seed (`80539`) makes it reproducible. It is **not** fit to
HWOL — manufacturing the published benefit→vacancy estimate from public inputs would mean
baking in the answer.

## Step 1 — build the synthetic DATA (one command)
```
stata-mp -b do code/build/Run_Synthetic_Data.do
```
This runs, in order: `Make_Synthetic_Vacancies.do` → `UIMacro_BuildData_Synthetic.do`
(the full build with `${vacfile}` = synthetic → the **SYNTH** vintage
`UIMacro_RevisionData_SYNTH.dta` / `UIMacro_DataControls_SYNTH.dta`) →
`Make_Synthetic_StateBorderData.do` (→ `StateMonthlyBorderData_synthetic.dta`).
Wages (`ProcessedWages`) are vacancy-independent and are not rebuilt.

## Step 2 — run each vacancy-gated artifact on the synthetic data
Each consumer takes a switch (set the global, then run; default = real/proprietary):

- **`tab:Benefits_on_JobCreation`** (Vacancies + Tightness rows) and **`tab:macroeffects_beg`**:
  `global DataControls "UIMacro_DataControls_SYNTH"` before
  `code/exporters/OutputDataSetsUIMacro_HWOL.do` (and `_Beg`) → `output/factor_inputs/HWOL/` →
  Matlab `code/matlab/Factor_FrontEnd_HWOL.m` (and `_Beg`) → `SenseResultsHWOL.csv` →
  `code/tex/make_tables.py`.
  *(The Employment row comes from QCEW — public, exact, no switch needed.)*
- **`tab:MO_V_U`** + the Missouri figures (`motight_*.pdf`):
  `global statefile "${maindirectory}StateMonthlyBorderData_synthetic.dta"` before
  `code/analysis/MO_Tightness_Figures.do`.
- **`tab:Imputed_Results`**: the imputation runs on `${vacfile}` (synthetic by default in
  `config.do`) — `analysis/Impute_Input.do` → Matlab `matlab/Run_Impute_Border.m` →
  `analysis/Impute_to_Stata.do`, which **builds `data/processed/ImputedDataBorder.dta`**
  (a built intermediate — **NOT shipped**; the replicator generates it by running this chain)
  → `analysis/Imputed_Results.do` reads it via `${ImputedFile}`. The Data Editor reproduces the
  published numbers by pointing `${vacfile}` at the licensed HWOL file and re-running the chain.

## Switch reference (all default to the real/proprietary file)
| global | script(s) | synthetic value |
|---|---|---|
| `${vacfile}` | `code/build/MakeDataSetsMainPaper_v5_newvac.do`, `code/analysis/Impute_Input.do` | `…/new_vac_synthetic.dta` |
| `${DataControls}` | `code/exporters/OutputDataSetsUIMacro_HWOL.do` (+`_Beg`) | `UIMacro_DataControls_SYNTH` |
| `${statefile}` | `code/analysis/MO_Tightness_Figures.do` | `…/StateMonthlyBorderData_synthetic.dta` |
| `${ImputedFile}` | `code/analysis/Impute_to_Stata.do`, `code/analysis/Imputed_Results.do` | `data/processed/ImputedDataBorder.dta` (BUILT by the imputation chain on `${vacfile}`; not shipped) |

For background on the proprietary vacancy data, see README section 6.
