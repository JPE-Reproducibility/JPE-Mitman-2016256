* ---------------------------------------------------------------------------
* 3_MakeQWITaxRate.do  ->  QWI_2018_09_18_t.dta   (QWI + state UI tax rate; build input)
*
* STAGE 3 of the 3-stage QWI chain. Appends the state UI-tax rate to QWI_2018_09_18:
* aggregates QWI private payroll to the state x fiscal-year level, merges the state UI tax
* receipts (UI_Tax_Data_Fips), and forms ui_tax_rate = 1000 * receipts / payroll. The result
* QWI_2018_09_18_t is the file MakeDataSetsMainPaper_v5_newvac.do merges in (consumed var:
* ui_tax_rate; the QWI wage/emp measures ride along).
*
* UI_Tax_Data_Fips provenance (state UI tax, separate input): produced upstream by
*   Import_State_UI_Tax_Data.do (-> UI_Tax_Data_Final -> UI_Tax_Data_Fips) in
*   built by BuildUITax.do from DOL/ETA state UI tax receipts (UI_Tax_Data_Final, data/raw/).
* ---------------------------------------------------------------------------
clear all
set more off

global QWIRAW "${rawdata}/QWI"
global TAXDATA "${rawdata}/UI_Tax_Data_Fips.dta"
global OUTDIR  "${rawdata}"

use "${QWIRAW}/QWI_2018_09_18", clear

gen fipsstate=floor(fipsnumeric/1000)

gen fiscal_quarter = quarter-2
replace fiscal_quarter = 3 if quarter==1
replace fiscal_quarter = 4 if quarter==2
gen fiscal_year = year
replace fiscal_year = fiscal_year+1 if quarter==3 | quarter==4

bys fipsstate fiscal_year: egen state_qwi_wagetot=sum(payrollall)

merge m:1 fipsstate fiscal_year using "${TAXDATA}"
drop if _merge==2
drop _merge

gen ui_tax_rate = 1000*UI_Tax_Receipts/state_qwi_wagetot

save "${OUTDIR}/QWI_2018_09_18_t", replace
