* ---------------------------------------------------------------------------
* Make_IndustryShares.do  ->  bea_industry_shares.dta
* County sample-average industry employment shares, used to build the cross-county
* industry-composition distance (tab:Benefits_on_unemp Col 6, the "similar industrial
* composition" subsample).
*
* SOURCE (provided raw): BEA Regional Economic Information System, table CA25N
*   "Total full-time and part-time employment by NAICS industry," county level.
*   Archive lapi1113-8/ (one CSV per state, CA25N_<ST>.csv; layout in CA25N_def.xml).
*   Each CSV is county x industry-line-code x year (2001-2012).
*
* CONSTRUCTION (paper sec. Col 6): for each county, the employment share of each of
* the 19 private-nonfarm NAICS industries (BEA line codes 100..1900) in PRIVATE NONFARM
* employment (line 90), averaged over the 2005-2012 sample. The build then forms the
* l2-distance between the two counties of each border pair from these average shares.
*
* OUTPUT: bea_industry_shares.dta, keyed fipsnumeric, with sh100..sh1900.
* ---------------------------------------------------------------------------
set more off
do "config.do"

local inds 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900
local dir "${rawdata}/lapi1113-8"
local files : dir "`dir'" files "CA25N_*.csv"
tempfile all
clear
save `all', emptyok replace
local kc1 90,100,200,300,400,500,600
local kc2 700,800,900,1000,1100,1200,1300
local kc3 1400,1500,1600,1700,1800,1900
foreach f of local files {
    if regexm("`f'","_US|_MSA|_MDIV|_PORT") continue          // skip non-county aggregates
    qui import delimited "`dir'/`f'", clear varnames(1) stringcols(_all)
    cap confirm variable v19
    if _rc continue
    qui keep geofips linecode v8-v19                          // v8..v19 = years 2001..2012
    qui destring geofips, gen(gf) force
    qui destring linecode, replace force
    qui drop if missing(gf) | mod(gf,1000)==0 | gf>=60000 | gf<1000   // counties only (drop SS000/US/regions/footer)
    qui keep if inlist(linecode,`kc1') | inlist(linecode,`kc2') | inlist(linecode,`kc3')
    qui append using `all'
    qui save `all', replace
}
use `all', clear
rename (v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19) (y2001 y2002 y2003 y2004 y2005 y2006 y2007 y2008 y2009 y2010 y2011 y2012)
foreach y of varlist y2001-y2012 {
    destring `y', replace force                               // "(D)" suppressed -> missing
}
drop geofips
reshape long y, i(gf linecode) j(year)
rename (y gf) (emp fipsnumeric)
reshape wide emp, i(fipsnumeric year) j(linecode)

* industry shares of private nonfarm employment (line 90)
foreach y of local inds {
    gen sh`y' = emp`y'/emp90
}
* sample-average shares over the 2005-2012 analysis window
keep if year>=2005 & year<=2012
collapse (mean) sh100-sh1900, by(fipsnumeric)
label data "BEA CA25N county sample-avg private-nonfarm industry shares (2005-2012)"
save "${rawdata}/bea_industry_shares.dta", replace
di "bea_industry_shares: N counties=" _N
