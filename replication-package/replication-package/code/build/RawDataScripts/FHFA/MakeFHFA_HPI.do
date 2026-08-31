* ---------------------------------------------------------------------------
* MakeFHFA_HPI.do  ->  NewFHFA_2018_07_26.dta  (FHFA county House Price Index)
* derived from the raw FHFA download.
*
* Raw: FHFA House Price Index, all-transactions, county, annual -- HPI_AT_BDL_county.xlsx
* (public, https://www.fhfa.gov/hpi/download). Header is on row 7 (rows 1-6 are notes).
*
* *** VINTAGE-SENSITIVE -- ship NewFHFA_2018_07_26.dta as a PROVIDED intermediate. ***
* FHFA back-revises the entire HPI series every release, so a CURRENT download does NOT
* reproduce the 2018-vintage values the paper used; this script reproduces
* NewFHFA_2018_07_26 only if run on the archived 2018-vintage xlsx. The
* shipped NewFHFA_2018_07_26.dta is the vintage-of-record (feeds tab:Endog_Vars).
* ---------------------------------------------------------------------------
cd "${rawdata}"
* cellrange(A7) open-ended (the 2018 vintage ended at row 82567; later vintages differ)
import excel "HPI_AT_BDL_county.xlsx", sheet("county") cellrange(A7) firstrow clear

rename FIPScode fipsnumeric
rename Year year
rename HPI fhfa_hpi
destring year, replace
destring fhfa_hpi, replace
destring fipsnumeric, replace

keep if year>2004 & year<2013
keep year fipsnumeric fhfa_hpi

save "NewFHFA_2018_07_26", replace
