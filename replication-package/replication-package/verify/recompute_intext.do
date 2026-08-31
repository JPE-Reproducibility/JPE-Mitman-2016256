* ---------------------------------------------------------------------------
* recompute_intext.do
*
* Recomputes the four in-text numbers that do not reproduce.
* Run from the package root (the directory holding code/, data/, output/):
*     do verify/recompute_intext.do
*
* Inputs (all ship in the archive):
*   data/processed/UIMacro_DataControls.dta   -> 1,132 ; 1,113 ; 59
*   data/processed/UIMacro_RevisionData.dta   -> 1.121 / 0.415
*   data/raw/claims_quarterly.dta             -> 1.121 / 0.415
*   data/raw/population_age.dta               -> 1.121 / 0.415
* ---------------------------------------------------------------------------
set more off
local proc "data/processed"
local raw  "data/raw"

* ============================== 1,132 ==============================
* Paper: of 1,172 pairs, 1,132 differ in benefits for at least one quarter;
* median 14 quarters; range 0 to 18.
* DataControls is already one row per pair-quarter (county_index==1) and
* carries the within-pair log benefit gap as diff_logmeanwks.
use pair_id_numeric year diff_logmeanwks using "`proc'/UIMacro_DataControls.dta", clear
keep if inrange(year,2008,2012)
gen byte differs = abs(diff_logmeanwks) > 1e-9 & !missing(diff_logmeanwks)
collapse (sum) ndiff=differs, by(pair_id_numeric)

count
di as txt "1,172 pairs total          -> " as res r(N)
count if ndiff > 0
di as txt "1,132 differing >=1 qtr    -> " as res r(N) as txt "   [MISS: +" as res r(N)-1132 as txt "]"
count if ndiff == 0
di as txt "   pairs never differing   -> " as res r(N) as txt " (paper implies 40)"
qui sum ndiff, detail
di as txt "14 median diff quarters    -> " as res r(p50)
di as txt "0 to 18 range              -> " as res r(min) as txt " to " as res r(max)
count if inrange(ndiff,1,3)
di as txt "   pairs differing in <=3 quarters: " as res r(N) as txt " (a small series shift moves the count easily)"

* ========================== 1,113 and 59 ===========================
* emp_share is built in code/build/MakeDataSetsMainPaper_v5_newvac.do L164-L166
* as emp_laus/emp_state_u in 2012q4, carried as a pair-constant.
* This mirrors code/analysis/Bias_Sim_Shares.do L26-L37.
use pair_id_numeric emp_share using "`proc'/UIMacro_DataControls.dta", clear
collapse (mean) emp_share, by(pair_id_numeric)
drop if missing(emp_share)

count if emp_share < 0.15
di as txt "1,113 below 15%            -> " as res r(N) as txt "   [MISS: " as res r(N)-1113 as txt "]"
count if emp_share >= 0.15
di as txt "59 at/above 15%            -> " as res r(N) as txt "   [MISS: +" as res r(N)-59 as txt "]"
qui sum emp_share if emp_share < 0.15
di as txt "2% avg share (small)       -> " as res %4.1f 100*r(mean)
qui sum emp_share if emp_share >= 0.15
di as txt "35% avg share (large)      -> " as res %4.1f 100*r(mean)

* Where the five pairs sit. The archived vintage puts five MORE pairs at or
* above the cutoff than the published text did, so recovering 1,113/59 needs
* the five lowest pairs ABOVE the line to fall below it.
sort emp_share
list emp_share if emp_share >= 0.15 & _n <= 1172, clean noobs
di as txt "   (the five lowest values above 0.15 are the ones that would have to move)"

* ======================= 1.121 and 0.415 ===========================
* NOTE: this one CANNOT come from UIMacro_DataControls.dta -- that file keeps
* only county_index==1, and the regression needs BOTH counties of each pair.
* Use UIMacro_RevisionData.dta.  Mirrors code/analysis/TableA2.do L113-L160.
use "`raw'/claims_quarterly.dta", clear
merge m:1 fipsnumeric year using "`raw'/population_age.dta", keep(match) keepusing(popestimate) nogen
gen fipsstate  = floor(fipsnumeric/1000)
gen claimspop  = cont_claims/popestimate

* State aggregate: sum claims over ALL counties / sum population.
preserve
    bysort fipsnumeric year: keep if _n==1
    collapse (sum) state_pop=popestimate, by(fipsstate year)
    tempfile sp
    save `sp'
restore
preserve
    collapse (sum) state_cc=cont_claims, by(fipsstate year quarter)
    merge m:1 fipsstate year using `sp', keep(match) nogen
    gen state_claimspop = state_cc/state_pop
    keep fipsstate year quarter state_claimspop
    tempfile st
    save `st'
restore
keep fipsnumeric year quarter claimspop
tempfile cp
save `cp'

use pair_id_numeric fipsnumeric year quarter county_index fipsstate ///
    using "`proc'/UIMacro_RevisionData.dta", clear
merge m:1 fipsnumeric year quarter using `cp', keep(master match) nogen
merge m:1 fipsstate  year quarter using `st', keep(master match) nogen

* "Other county" = the adjacent out-of-state county in the same pair-quarter.
sort pair_id_numeric year quarter county_index
by pair_id_numeric year quarter: gen cp1 = claimspop[1]
by pair_id_numeric year quarter: gen cp2 = claimspop[2]
gen othercp = cp1 if county_index==2
replace othercp = cp2 if county_index==1

reg claimspop othercp state_claimspop if year==2007
di as txt "1.121 state coefficient    -> " as res %5.3f _b[state_claimspop] as txt "   [MISS]"
di as txt "0.415 adjacent coefficient -> " as res %5.3f _b[othercp]         as txt "   [MISS]"
di as txt "   original producing script was lost; the shipped version is a reconstruction"
