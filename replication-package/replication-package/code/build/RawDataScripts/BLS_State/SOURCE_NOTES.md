# BLS_State — state quarterly employment

**Producer:** `Make_StateEmp.do` → `state_emp_quarterly.dta`

**Source (public):** U.S. Bureau of Labor Statistics, Local Area Unemployment Statistics (LAUS)
state series — `la.data.2.AllStatesU` (not seasonally adjusted) and `la.data.3.AllStatesS`
(seasonally adjusted), **2013-06-22 vintage**. In each series_id, characters 6–7 are the state
FIPS (BLS code 43 = Puerto Rico → 72) and character 13 is the measure (`5` = employment);
`period` is `M01`–`M12` (`M13` = annual average, dropped). Download: https://www.bls.gov/lau/.

**What it builds:** monthly state employment (SA + unadjusted), measure 5, collapsed to a
quarterly mean → `emp_state_sa` and `emp_state_u`, keyed `fipsstate year quarter`. The build
uses `emp_state_u` for `emp_share` (Column 5 subsample) and `emp_state_sa` for `prod_all_old`
(the State-GDP-per-worker control in the OLS table).

