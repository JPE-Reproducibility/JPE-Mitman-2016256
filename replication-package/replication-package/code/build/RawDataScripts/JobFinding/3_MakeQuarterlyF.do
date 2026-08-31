* ---------------------------------------------------------------------------
* 3_MakeQuarterlyF.do  ->  quarterly_f.dta   (quarterly county job-finding; build input)
*
* Aggregates the monthly job-finding probability (jobfindfp_v12) to the quarter:
* bounds f_cl in [0.01,0.99] and f_cl2 in [0.05,0.95], compounds the three monthly
* rates into a quarterly job-finding rate f_cl_q = 1-(1-f1)(1-f2)(1-f3), and collapses
* to county x quarter. Feeds f_cl/f_cl2/f_cl_q/f_cl2_q -> logf_cl* in the build, used by
* the JFR (job-finding-rate) IFE experiment (code/exporters/OutputDataSetsUIMacro_JFR.do)
* and code/analysis/Impute_Input.do.
* ---------------------------------------------------------------------------
clear all
set more off

use "${rawdata}/jobfindfp_v12.dta", clear
gen quarter=floor((month-1)/3)+1

gen f_cl=ffp
gen f_cl2=f_cl
replace f_cl=0.01  if f_cl<0.01   & ffp~=.
replace f_cl=0.99  if f_cl>0.99   & ffp~=.
replace f_cl2=0.05 if f_cl2<0.05  & ffp~=.
replace f_cl2=0.95 if f_cl2>0.95  & ffp~=.

sort fipsnumeric year quarter month
by fipsnumeric year quarter: gen f_cl_q =1-(1-f_cl[1]) *(1-f_cl[2]) *(1-f_cl[3])
by fipsnumeric year quarter: gen f_cl2_q=1-(1-f_cl2[1])*(1-f_cl2[2])*(1-f_cl2[3])

collapse (mean) f_cl_q f_cl2_q (sum) f_cl f_cl2 ffp, by(fipsnumeric year quarter)

save "${rawdata}/quarterly_f.dta", replace
