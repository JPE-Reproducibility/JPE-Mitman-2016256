* ---------------------------------------------------------------------------
* Make_Saiz_Elasticity.do  ->  housing_elasticity.dta
* Builds the county-level land-supply instruments the main build merges
* (MakeDataSetsMainPaper_v5_newvac.do, merge m:1 fipsnumeric):
*   elasticity  Saiz (2010) housing-supply elasticity
*   WRLURI      Wharton Residential Land Use Regulatory Index
* These feed diff_elas / diff_wharton in MakeDataControls.do, the EXCLUDED INSTRUMENTS
* for the house-price term (diff_fhfa_lev) in the Col-3 IV-GLS of tab:Endog_Vars
* (code/analysis/Endog_Vars.do: ... (diff_fhfa_lev = diff_elas diff_wharton)).
*
* SOURCE (provided, citable raw): HOUSING_SUPPLY.dta -- the MSA-level elasticity/WRLURI
* file from the replication kit for
*   Saiz, A. (2010). "The geographic determinants of housing supply." Quarterly Journal
*   of Economics, 125(3), 1253-1296.
*   kit: https://drive.google.com/uc?id=1RnTT3f6w2LHjH7iPKnXqlTTkeHeMQ8ea&export=download
* It is keyed by `msanecma` (old MSA/NECMA/PMSA codes). Two public Census geography
* crosswalks map it to counties: cbsa_msanecma.dta (msanecma -> CBSA) and
* cbsa_county.dta (CBSA -> county FIPS). All three ship in ${rawdata}/.
*
* DEDUP NOTE: six combined metros map >1 old MSA/PMSA to a single CBSA --
* Dallas-Fort Worth (19100), Miami-Fort Lauderdale-West Palm Beach (33100),
* New York-Newark-Jersey City (35620), Philadelphia-Camden-Wilmington (37980),
* San Francisco-Oakland (41860), Seattle-Tacoma (42660) -- each with a different Saiz
* elasticity. A plain `bys cbsa_code: keep if _n==1` would pick among them by sort order
* (tie-break-dependent). We instead pin each of the six to a fixed msanecma, so the
* county elasticity assigned to these metros is deterministic.
* ---------------------------------------------------------------------------
clear all
set more off
global DATA "${rawdata}"

use "${DATA}/HOUSING_SUPPLY.dta", clear
merge 1:m msanecma using "${DATA}/cbsa_msanecma.dta"
keep if _merge==3
drop _merge

* one MSA per CBSA. For the six multi-MSA CBSAs, pin each to a fixed msanecma so the
* selection is deterministic (a plain keep-_n==1 would be sort-order-dependent);
* all other CBSAs have a single row.
gen byte _pri = 1
replace _pri = 0 if (cbsa_code==19100 & msanecma==1920) | ///   Dallas-Fort Worth -> Dallas
                    (cbsa_code==33100 & msanecma==8960) | ///   Miami -> West Palm Beach
                    (cbsa_code==35620 & msanecma==3640) | ///   NY -> Jersey City
                    (cbsa_code==37980 & msanecma==9160) | ///   Philadelphia -> Wilmington
                    (cbsa_code==41860 & msanecma==7360) | ///   SF-Oakland -> San Francisco
                    (cbsa_code==42660 & msanecma==7600)         //  Seattle-Tacoma -> Seattle
bysort cbsa_code (_pri msanecma): keep if _n==1
drop _pri

merge 1:m cbsa_code using "${DATA}/cbsa_county.dta"
keep if _merge==3
drop _merge

rename fips fipsnumeric
rename fips_state_code fipsstate
keep fipsnumeric elasticity WRLURI
sort fipsnumeric
save "${DATA}/housing_elasticity", replace
