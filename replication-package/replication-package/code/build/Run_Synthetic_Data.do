* ---------------------------------------------------------------------------
* Run_Synthetic_Data.do  --  one-command build of the synthetic-vacancy DATA inputs
* for running the kit without the proprietary HWOL data. See SYNTHETIC_VACANCY_PATH.md
* for the full story + how to run the vacancy-gated tables/figures on the output.
*
* Produces (all in synthetic-data/ / data/raw/):
*   1. new_vac_synthetic.dta                        (public-data synthetic county vacancies)
*   2. UIMacro_RevisionData_SYNTH / _DataControls_SYNTH  (full build on synthetic vacancies)
*   3. StateMonthlyBorderData_synthetic.dta         (state panel for the Missouri figures)
*
* *** The resulting vacancy-gated results are DEMONSTRATIVE, not a reproduction ***
* (the published numbers require the licensed HWOL data). Everything not vacancy-gated
* is exact. Run from anywhere: stata-mp -b do code/build/Run_Synthetic_Data.do
* ---------------------------------------------------------------------------
set more off
do "config.do"

* each step is self-contained (sets its own globals; the build does its own clear all)
do ${code}/build/Make_Synthetic_Vacancies.do
do ${code}/build/UIMacro_BuildData_Synthetic.do
do ${code}/build/Make_Synthetic_StateBorderData.do

display "Synthetic-vacancy DATA build complete. See SYNTHETIC_VACANCY_PATH.md step 2."
