* ---------------------------------------------------------------------------
* Make_PlaceboWeeksData.do  ->  ${rawdata}/PlaceboWeeksData.dta
*
* Builds the ARTIFICIAL placebo-benefit-weeks panel used by the placebo test
* (§sec:placebo_test; inline numbers 0.008/0.35 and the 1996-2001 footnote 0.015).
*
* Recipe: starting from public BLS state monthly unemployment rates (unadjusted +
* seasonally adjusted), assign each state-month a HYPOTHETICAL maximum-benefit-weeks
* schedule = 26 base weeks, bumped to 26+13=39 whenever the trailing 3-month average
* of the state unemployment rate exceeds a threshold x (4/5/6/7 percent), under both
* the unadjusted (pwks_u{x}_13) and seasonally-adjusted (pwks_sa{x}_13) rate, then
* collapse to (fipsstate year quarter). The paper's reported placebo trigger is
* sa6 (3-mo avg SA state urate > 6%). No real benefit extensions occur in 1996-2000,
* so any estimated "effect" of this fake schedule is a placebo.
*
* INPUTS (public BLS LAUS state monthly rates, copied into $maindirectory):
*   laus_state_u.dta   : fipsstate year month state_unemp_rate_u   (NOT seas. adj.)
*   laus_state_sa.dta  : fipsstate year month state_unemp_rate_sa  (seas. adj.)
* Both span 1976-2015, in percent (BLS LAUS state series; rebuilt from the raw
*   extracts by LAUS steps 6-7).
* OUTPUT: PlaceboWeeksData.dta keyed (fipsstate year quarter) with pwks_{u,sa}{4,5,6,7}_13
* (plus state* and the switch/on indicators), consumed by
* code/exporters/OutputDataSetsUIMacro_Placebo.do via ${placebofile}.
* ---------------------------------------------------------------------------

do "config.do"
global maindirectory = "${rawdata}/"
cd "$maindirectory"

set more off, perm

use "${rawdata}/laus_state_u.dta", clear
merge 1:1 fipsstate year month using "${rawdata}/laus_state_sa.dta"
drop _merge

gen month_index=(year-2005)*12+month
xtset fipsstate month_index

* trailing 3-month average of the state unemployment rate (the extension trigger)
by fipsstate: gen lagged_q_u_u  = (L1.state_unemp_rate_u +L2.state_unemp_rate_u +L3.state_unemp_rate_u )/3
by fipsstate: gen lagged_q_u_sa = (L1.state_unemp_rate_sa+L2.state_unemp_rate_sa+L3.state_unemp_rate_sa)/3

forvalues y=13/13{
forvalues x=4/7{

	gen pwks_u`x'_`y'=26
	gen pwks_sa`x'_`y'=26

	replace pwks_u`x'_`y'=26+`y' if lagged_q_u_u>`x'
	replace pwks_sa`x'_`y'=26+`y' if lagged_q_u_sa>`x'

}
}

gen quarter = ceil(month/3)

collapse state* pwks_* lagged*, by(fipsstate year quarter)

sort fipsstate year quarter
gen quarter_index=(year-2005)*4+quarter
xtset fipsstate quarter_index

forvalues y=13/13{
forvalues x=4/7{

	gen switch_u`x'_`y'=0
	gen switch_sa`x'_`y'=0
	gen on_u`x'_`y'=0
	gen on_sa`x'_`y'=0

	by fipsstate: replace switch_u`x'_`y'=1  if D1.pwks_u`x'_`y'~=0 & D1.pwks_u`x'_`y'~=.
	by fipsstate: replace switch_sa`x'_`y'=1 if D1.pwks_sa`x'_`y'~=0 & D1.pwks_sa`x'_`y'~=.

	by fipsstate: replace on_u`x'_`y'=1  if pwks_u`x'_`y'>26 & pwks_u`x'_`y'~=.
	by fipsstate: replace on_sa`x'_`y'=1 if pwks_sa`x'_`y'>26 & pwks_sa`x'_`y'~=.

}
}

save "${rawdata}/PlaceboWeeksData.dta", replace
