# Job-finding chain → `quarterly_f.dta` (build input)

County job-finding rates backed out of continuing-claims flows. Feeds
`f_cl`/`f_cl2`/`f_cl_q`/`f_cl2_q` → `logf_cl*` in the build, consumed by the **JFR**
(job-finding-rate) IFE experiment (`code/exporters/OutputDataSetsUIMacro_JFR.do`) and
`code/analysis/Impute_Input.do`. Three layers, run in order:

1. **`step1_backoutf_fp.m`** (MATLAB) — county continuing-claims QBLS → `jobfindingfp_v12.txt`.
   Reads `CLAIMS/COUNTY/Output/CountyClaims/QBLS{i}.txt` (1268 counties), computes the
   claims exit rate, seeds the last 6 months with CPS L26-Shimer job-finding rates, and
   runs the backward duration recursion. Deterministic (no optimizer/RNG).
   *(`backoutf_fp_cohort.m` writes the same filename by a different cohort method — the
   forward routine here is the production one.)*
2. **`2_makejobfind.do`** — `jobfindingfp_v12.txt` → `jobfindfp_v12.dta` (insheet + rename).
3. **`3_MakeQuarterlyF.do`** — `jobfindfp_v12.dta` → `quarterly_f.dta` (bound, compound
   monthly→quarterly, collapse to county×quarter).


## Raw / upstream
- County continuing-claims QBLS (~18 MB, 1268 files), shipped in
  `data/raw/claims/CountyClaims/`. These administrative claims records are the
  back-out's input (provided; compiled from county UI continuing-claims data).
