* ---------------------------------------------------------------------------
* 2_makejobfind.do  ->  jobfindfp_v12.dta
*
* Imports the backed-out monthly job-finding probabilities (jobfindingfp_v12.txt,
* written by step1_backoutf_fp.m) into Stata.
* ---------------------------------------------------------------------------
clear all
set more off

insheet using "${rawdata}/claims/jobfindingfp_v12.txt", clear
rename v1 fipsnumeric
rename v2 year
rename v3 month
rename v4 ffp
sort fipsnumeric year month
save "${rawdata}/jobfindfp_v12.dta", replace
