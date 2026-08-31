* ---------------------------------------------------------------------------
* 2_MakeQWI_2018_09_18.do  ->  QWI_2018_09_18.dta   (county QWI wage/employment measures)
*
* STAGE 2 of the 3-stage QWI chain. Keeps county-level (geo_level=="C") rows, maps NAICS
* sector codes to short tags, reshapes wide by industry, then builds the QWI wage measures
* (qwiw1-4 stable-job earnings, qwi_wnh/wah/wtot, the f-suffixed "significant-flag" variants)
* and sector employment (qwi_emp_*, qwif_emp_*) for five industries.
*
* SECTOR NOTE: the wage/emp loops run over "all" "ret" "foo" "art" "man". The downstream
* consumers are ALL (everywhere) and RET + FOO (non-tradable sector shares, table in the
* TeX near L1090). MAN and "art" are also constructed and retained in the ~30-column output.
* ---------------------------------------------------------------------------
clear all
set more off

global QWIRAW "${rawdata}/QWI"
cd "${QWIRAW}"

use  QWI_VintageQ32014, clear

keep if geo_level=="C"

replace industry="all" if industry=="00"
replace industry="agg" if industry=="11"
replace industry="min" if industry=="21"
replace industry="utl" if industry=="22"
replace industry="con" if industry=="23"
replace industry="who" if industry=="42"
replace industry="inf" if industry=="51"
replace industry="fin" if industry=="52"
replace industry="rea" if industry=="53"
replace industry="pro" if industry=="54"
replace industry="com" if industry=="55"
replace industry="adm" if industry=="56"
replace industry="edu" if industry=="61"
replace industry="hea" if industry=="62"
replace industry="art" if industry=="71"
replace industry="foo" if industry=="72"
replace industry="ser" if industry=="81"
replace industry="pub" if industry=="92"
replace industry="oth" if industry=="99"
replace industry="man" if industry=="31-33"
replace industry="ret" if industry=="44-45"
replace industry="tra" if industry=="48-49"

reshape wide emp	empend	emps	empspv	emptotal	hira	hirn	hirr	sep	hiraend	hiraendr	sepbeg	sepbegr	hiras	hirns	seps	sepsnx	turnovrs	frmjbgn	frmjbls	frmjbc	hiraendrepl	hiraendreplr	frmjbgns	frmjblss	frmjbcs	earns	earnbeg	earnhiras	earnhirns	earnseps	payroll geo_level semp sempend semps sempspv semptotal shira shirn shirr ssep shiraend shiraendr ssepbeg ssepbegr shiras shirns sseps ssepsnx sturnovrs sfrmjbgn sfrmjbls sfrmjbc shiraendrepl shiraendreplr sfrmjbgns sfrmjblss sfrmjbcs searns searnbeg searnhiras searnhirns searnseps spayroll, i(year quarter geograph) j(industry) string

save QWIwidecounty, replace

use QWIwidecounty, clear

rename geography fipsnumeric

gen quarter_index=(year-1990)*4+quarter

sort fipsnumeric quarter_index

foreach ind in "all" "ret" "foo" "art" "man"{

***Earnings of stable jobs minus earnings of hires into stable jobs div by number
by fipsnumeric: gen qwiw1_`ind'=(emps`ind'[_n]*earns`ind'[_n]-hiras`ind'[_n]*earnhiras`ind'[_n])/(emps`ind'[_n]-hiras`ind'[_n])
***Earnings of stable jobs minus earnings of separators from stable jobs div by number
by fipsnumeric: gen qwiw2_`ind'=(emps`ind'[_n]*earns`ind'[_n]-seps`ind'[_n+1]*earnseps`ind'[_n])/(emps`ind'[_n]-seps`ind'[_n+1])

gen qwi_wnh_`ind'= earnhirns`ind'
gen qwi_wah_`ind'= earnhiras`ind'
gen qwi_wtot_`ind'= earns`ind'

***Earnings of stable jobs minus earnings of hires into stable jobs div by number
by fipsnumeric: gen qwiw3_`ind'=(empspv`ind'[_n]*earns`ind'[_n]-hiras`ind'[_n-1]*earnhiras`ind'[_n-1])/(empspv`ind'[_n]-hiras`ind'[_n-1])
***Earnings of stable jobs minus earnings of separators from stable jobs div by number
by fipsnumeric: gen qwiw4_`ind'=(empspv`ind'[_n]*earns`ind'[_n]-sepsnx`ind'[_n-1]*earnseps`ind'[_n])/(emps`ind'[_n]-sepsnx`ind'[_n-1])

rename emp`ind' qwi_emp_`ind'

}

foreach ind in "all" "ret" "foo" "art" "man"{

gen femps`ind' = emps`ind' if semps`ind' == 1
gen fearns`ind' = earns`ind' if searns`ind' == 1
gen fearnhiras`ind' = earnhiras`ind' if searnhiras`ind' == 1
gen fearnseps`ind' = earnseps`ind' if searnseps`ind' == 1
gen fseps`ind' = seps`ind' if sseps`ind' == 1
gen fhiras`ind' = hiras`ind' if shiras`ind' == 1

gen fempspv`ind' = empspv`ind' if sempspv`ind' == 1
gen fsepsnx`ind' = sepsnx`ind' if ssepsnx`ind' == 1

***Earnings of stable jobs minus earnings of hires into stable jobs div by number
by fipsnumeric: gen qwiw1f_`ind'=(femps`ind'[_n]*fearns`ind'[_n]-fhiras`ind'[_n]*fearnhiras`ind'[_n])/(femps`ind'[_n]-fhiras`ind'[_n])
***Earnings of stable jobs minus earnings of separators from stable jobs div by number
by fipsnumeric: gen qwiw2f_`ind'=(femps`ind'[_n]*fearns`ind'[_n]-fseps`ind'[_n+1]*fearnseps`ind'[_n])/(femps`ind'[_n]-fseps`ind'[_n+1])

gen qwi_wnhf_`ind'= earnhirns`ind' if searnhirns`ind'==1
gen qwi_wahf_`ind'= earnhiras`ind' if searnhiras`ind'==1
gen qwi_wtotf_`ind'= earns`ind' if earns`ind'==1

***Earnings of stable jobs minus earnings of hires into stable jobs div by number
by fipsnumeric: gen qwiw3f_`ind'=(femps`ind'[_n]*fearns`ind'[_n]-fhiras`ind'[_n]*fearnhiras`ind'[_n])/(femps`ind'[_n]-fhiras`ind'[_n])
***Earnings of stable jobs minus earnings of separators from stable jobs div by number
by fipsnumeric: gen qwiw4f_`ind'=(fempspv`ind'[_n]*fearns`ind'[_n-1]-fseps`ind'[_n]*fearnseps`ind'[_n-1])/(fempspv`ind'[_n]-fseps`ind'[_n])

gen qwif_emp_`ind' = qwi_emp_`ind' if semp`ind'==1
}

rename qwi_emp_all qwi_emp

save QWI_2018_09_18, replace
