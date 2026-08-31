* ---------------------------------------------------------------------------
* Make_Synthetic_Vacancies.do  ->  synthetic stand-in for the proprietary HWOL
*                                  county-vacancy file new_vac_april2017.dta
*
* WHY: the published vacancy/tightness/imputation results use The Conference
* Board's Help-Wanted OnLine (HWOL) county vacancy counts, which are PROPRIETARY
* and cannot be redistributed. This script builds
* a SYNTHETIC replacement with the same schema and coverage, calibrated from
* PUBLIC data only, so the full pipeline runs end-to-end and is auditable.
*
* *** The synthetic data are DEMONSTRATIVE, not a reproduction. *** They give
* realistic vacancy LEVELS and cross-county / time STRUCTURE (so tightness and the
* border imputation come out sensible), but they do NOT and cannot manufacture the
* published benefit->vacancy causal estimate from public inputs without baking in
* the answer. Vacancy-gated tables/figures run on this file but their numbers are
* illustrative; the published numbers require the licensed HWOL data.
*
* MODEL (public inputs only):
*   vacancy rate (per worker), county c, quarter:
*     vacrate_ct = openings_rate_y * exp( -beta*(urate_ct - urate_nat_t) + eps_ct )
*   where
*     openings_rate_y : national JOLTS job-openings rate (BLS, public), by year
*                       -- supplies the level + the Great-Recession dip/recovery;
*     urate_ct        : county unemployment rate (LAUS, public, in CurrentData);
*     urate_nat_t     : cross-county mean unemployment rate that quarter (public);
*     beta            : Beveridge slope (tighter labor market -> more vacancies);
*     eps_ct          : reproducible (seeded) persistent county deviation + small
*                       transitory noise -> realistic dispersion & persistence.
*   total_vacancies_county = vacrate * employment (LAUS).
*   total_newvacancies_county = NEWVAC_FRAC * total (vacancy-duration assumption,
*                       NOT taken from the proprietary file).
*   Quarterly values are expanded to 3 identical months (the build collapses the
*   monthly vacancy file back to a quarterly mean, so within-quarter detail is
*   irrelevant) and written with the HWOL schema:
*     fipsnumeric year month total_vacancies_county total_newvacancies_county
*
* OUTPUT: synthetic-data/new_vac_synthetic.dta. To use it, point the
* build's vacancy merge at this file (the ${vacfile} switch in
* MakeDataSetsMainPaper_v5_newvac.do), then re-run the build.
* ---------------------------------------------------------------------------

do "config.do"
do "config.do"

set more off, perm
set seed 80539      // reproducibility of the idiosyncratic deviations

* --- calibration constants (modeling choices, documented; NOT from HWOL) ---
local beta     = 0.10    // Beveridge slope per percentage point of unemployment
local sd_perm  = 0.30    // sd of the persistent county vacancy-rate deviation
local sd_trans = 0.10    // sd of the transitory quarterly deviation
local newfrac  = 0.50    // new vacancies / total (vacancy duration ~ 2 months)

* --- national JOLTS job-openings RATE (%), annual, BLS JTS total nonfarm (public).
*     2005-2016 (HWOL coverage); supplies the level and the recession profile. ---
matrix OPEN = (3.0, 3.1, 3.2, 2.6, 1.7, 2.1, 2.4, 2.7, 2.8, 3.3, 3.7, 3.8)
* indexed by (year-2004): 1=2005 ... 12=2016

* ============================ build the county base ============================
use fipsnumeric year quarter emp_laus unemp_count_laus unemp_rate_laus ///
    using "${maindirectory}${CurrentData}", clear

* one row per county-quarter (CurrentData repeats counties across pairs)
bys fipsnumeric year quarter: keep if _n==1

keep if year>=2005 & year<=2016
drop if missing(emp_laus, unemp_rate_laus) | emp_laus<=0

* national (cross-county mean) unemployment rate each quarter, for the deviation
bys year quarter: egen urate_nat = mean(unemp_rate_laus)

* national openings rate for the year
gen open_rate = .
forvalues y=2005/2016 {
    local k = `y'-2004
    quietly replace open_rate = OPEN[1,`k']/100 if year==`y'
}

* --- reproducible deviations: persistent county effect + transitory noise ---
bys fipsnumeric (year quarter): gen long _cseq = (_n==1)
sort fipsnumeric year quarter
by fipsnumeric: gen perm_dev = `sd_perm'*rnormal() if _n==1
by fipsnumeric: replace perm_dev = perm_dev[1]
gen trans_dev = `sd_trans'*rnormal()

* --- synthetic vacancy rate and counts ---
gen vacrate = open_rate*exp(-`beta'*(unemp_rate_laus-urate_nat) + perm_dev + trans_dev)
gen total_vacancies_county    = vacrate*emp_laus
gen total_newvacancies_county = `newfrac'*total_vacancies_county

keep fipsnumeric year quarter total_vacancies_county total_newvacancies_county

* --- expand quarterly -> 3 monthly rows (build re-collapses to a quarterly mean) ---
expand 3
bys fipsnumeric year quarter: gen _m = _n
gen month = 3*(quarter-1) + _m
drop _m quarter

order fipsnumeric year month total_vacancies_county total_newvacancies_county
sort fipsnumeric year month
label data "SYNTHETIC county vacancies (public-data calibrated; NOT HWOL)"
save "${synthetic}/new_vac_synthetic.dta", replace
