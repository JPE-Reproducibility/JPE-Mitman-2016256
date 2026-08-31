* ---------------------------------------------------------------------------
* MakeBartikShocks.do  ->  bartik_shocks.dta   (county Bartik labor-demand shocks)
* ---------------------------------------------------------------------------
clear all
set maxvar 32000
set more off

global direc "${rawdata}/"
global LAUSB  = "${rawdata}/NewLAUSBorderData2014_final24Nov16"
global QWI18  = "${rawdata}/QWI/QWI_2018_09_18.dta"

use "${LAUSB}"

merge m:1 fipsnumeric year quarter using "${QWI18}"

replace fipsstate =floor(fipsnumeric/1000) if fipsstate ==.
gen nonborder=0
replace nonborder=1 if _merge==2

bys fipsnumeric year quarter: keep if _n==1

* value-preserving bridge (see header)
foreach i in "agg" "min" "utl" "con" "who" "inf" "fin" "rea" "pro" "com" "adm" "edu" "hea" "ser" "pub" "tra" {
    capture confirm variable qwi_emp_`i'
    if _rc {
        rename emp`i' qwi_emp_`i'
    }
}

bys year quarter: egen nat_qwi_all=sum(qwi_emp)
bys fipsstate year quarter: egen state_qwi_all=sum(qwi_emp)
bys fipsstate year quarter nonborder: egen temp_qwi_all=sum(qwi_emp)
replace temp_qwi_all=-10000 if nonborder==0
bys fipsstate year quarter: egen hinter_qwi_all=max(temp_qwi_all)
drop temp_qwi_all

foreach i in "agg" "min" "utl" "con" "who" "inf" "fin" "rea" "pro" "com" "adm" "edu" "hea" "art" "foo" "ser" "pub" "man" "ret" "tra" {
bys year quarter: egen nat_qwi_`i'=sum(qwi_emp_`i')
bys fipsstate year quarter: egen state_qwi_`i'=sum(qwi_emp_`i')
bys fipsstate year quarter nonborder: egen temp_qwi_`i'=sum(qwi_emp_`i')
replace temp_qwi_`i'=0 if nonborder==0
bys fipsstate year quarter: egen hinter_qwi_`i'=max(temp_qwi_`i')
drop temp_qwi_`i'
gen xstate_qwi_`i'=nat_qwi_`i'-state_qwi_`i'
gen xhinter_qwi_`i'=nat_qwi_`i'-hinter_qwi_`i'
gen xcounty_qwi_`i'=nat_qwi_`i'-qwi_emp_`i'
gen tstate_share_`i'=0
gen thinter_share_`i'=0
gen tcounty_share_`i'=0
replace tstate_share_`i'=state_qwi_`i'/state_qwi_all if year==2004 & quarter==1
replace thinter_share_`i'=hinter_qwi_`i'/hinter_qwi_all if year==2004 & quarter==1
replace tcounty_share_`i'=qwi_emp_`i'/qwi_emp if year==2004 & quarter==1
bys fipsstate: egen state_share_`i'=max(tstate_share_`i')
bys fipsstate: egen hinter_share_`i'=max(thinter_share_`i')
bys fipsnumeric: egen county_share_`i'=max(tcounty_share_`i')
drop tstate_share_`i'
drop thinter_share_`i'
drop tcounty_share_`i'
}

tsset fipsnumeric quarter_index

foreach i in "agg" "min" "utl" "con" "who" "inf" "fin" "rea" "pro" "com" "adm" "edu" "hea" "art" "foo" "ser" "pub" "man" "ret" "tra" {
    gen dnat_`i'=ln(nat_qwi_`i')-ln(L.nat_qwi_`i')
}

gen bartik_state=0
gen bartik_hinter=0
gen bartik_county=0

foreach i in "agg" "min" "utl" "con" "who" "inf" "fin" "rea" "pro" "com" "adm" "edu" "hea" "art" "foo" "ser" "pub" "man" "ret" "tra" {
    replace bartik_state=bartik_state+state_share_`i'*dnat_`i'
    replace bartik_hinter=bartik_hinter+hinter_share_`i'*dnat_`i'
    replace bartik_county=bartik_county+county_share_`i'*dnat_`i'
}

keep fipsnumeric year quarter quarter_index bartik_*
save "${rawdata}/bartik_shocks", replace
