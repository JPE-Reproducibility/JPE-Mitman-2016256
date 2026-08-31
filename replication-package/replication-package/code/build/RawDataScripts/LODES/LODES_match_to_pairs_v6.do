clear all
capture log close
set more off
* pair list source: the shipped border panel (pair_id_numeric/county_index/fipsnumeric
* are identical to every RevisionData vintage, which is built from it)
global CurrentData = "NewLAUSBorderData2014_final24Nov16.dta"
global path_county_data "${rawdata}"
global lodescode "${code}/build/RawDataScripts/LODES"
global maindir "${rawdata}"
global sep = "/"
* flat layout: inputs/outputs live directly in the data dir; the helper script
* (TransposePairs.do) lives next to this file
global inputdir = "${maindir}"
global outputdir = "${maindir}"
global codedir = "${lodescode}"
global logfile=c(current_date)
global logfile=subinstr("$logfile"," ","_",.)
global logfile="matching_LODES_to_borderpairs_$logfile"

*capture noisily log using "${outputdir}${sep}logfile.log", replace

cd "$path_county_data"
u ${CurrentData}, clear
sort pair_id_numeric year quarter county_index
duplicates drop pair_id_numeric county_index, force
keep pair_id_numeric county_index fipsnumeric
drop if pair_id_numeric==.
reshape wide fipsnumeric, i(pair_id_numeric) j(county_index)
ren fipsnumeric1 h_cty
ren fipsnumeric2 w_cty

gen h_st = floor(h_cty/1000)
gen w_st = floor(w_cty/1000)
drop if h_st==w_st		// normally this shouldn't happen, but our pair data has (very few) wrong observations.
cd $inputdir
save county_pairs, replace

cd $codedir
do TransposePairs


cd $inputdir

* Step 1: Obtain total residents in a county that work
u aggregate_byresidence
merge 1:m year h_cty using $inputdir${sep}commuter_countyFlows, nogen
keep year h_cty w_cty workers fl_* in_county_workers

sort year h_cty w_cty
bys year h_cty: egen emp_byresidence = sum(workers)

* Step 2: Compute out-of-state commuters
ren workers commuters

gen h_st = floor(h_cty/1000)
gen w_st = floor(w_cty/1000)
order year h_cty w_cty h_st w_st

by year h_cty: egen temp = sum(commuters) if h_st ~= w_st
by year h_cty: egen commuter_outofstate = min(temp)
gen fr_st_commuter = commuter_outofstate/emp_byresidence
drop temp
*br year h_cty w_cty h_st w_st commuters commuter_outofstate emp_byresidence share_commuter_state


* Step 3: Compute commuters for county pairs
drop if h_cty == w_cty
drop if h_st  == w_st
gen fr_cty_commuter = commuters/emp_byresidence /*if h_cty ~= w_cty*/

foreach var of varlist fr_st_commuter commuters fr_cty_commuter{
replace `var'=. if in_county_workers==0
}


order year h_cty  w_cty h_st w_st commuters emp_byresidence fr_st_commuter fr_cty_commuter fl_* in_county_workers
keep  year h_cty  w_cty h_st w_st commuters emp_byresidence fr_st_commuter fr_cty_commuter fl_* in_county_workers




sort year h_cty w_cty
* Step 3: Add variable labels
la var h_cty "County of residence"
la var w_cty "County of work"
la var h_st "State of residence"
la var w_st "State of work"
la var emp_byresidence "Employed residents"
/*la var commuters "# Commuters"
la var commuter_outofstate "# Commuters out of state"*/
la var fr_cty_commuter "fraction commuters by county pairs"
la var fr_st_commuter "fraction commuters out of state"
la var fl_miss "Flag for affected state-years"
la var fl_neighbor "Flag for affected neighboring states"

cd $outputdir
*erase aggregate_byresidence_total.dta
*capture noisily log close

* merge to border county pairs
sort h_cty w_cty year
merge m:1 h_cty w_cty using $inputdir${sep}county_pairs_1

drop if _merge==2		// 2 pairs not matched.

// gen whether_pair=.
// replace whether_pair=1 if _merge==3
// replace whether_pair=0 if _merge==1
drop _merge

merge m:1 h_cty w_cty using $inputdir${sep}county_pairs_2
drop if _merge==2		// 2 pairs not matched.
// replace whether_pair=1 if _merge==3
// replace whether_pair=0 if _merge==1
drop _merge

replace pair_id_numeric = pair_id_numeric2 if pair_id_numeric==. & pair_id_numeric2~=.
replace county_index = county_index2 if county_index==. & county_index2~=.

keep if pair_id_numeric~=.
drop county_index2 pair_id_numeric2


save fraction_commuters_lite_flag, replace
