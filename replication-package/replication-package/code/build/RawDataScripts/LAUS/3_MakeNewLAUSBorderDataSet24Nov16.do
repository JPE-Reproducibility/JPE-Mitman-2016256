* ---------------------------------------------------------------------------
* 3_MakeNewLAUSBorderDataSet24Nov16.do  ->  NewLAUSBorderData2014_final24Nov16.dta
* THE CORE INPUT of the main build: the balanced border-county-pair monthly
* panel 1990-2014 (county pairs straddling a state border), carrying the LAUS
* unemployment block and meanwks. UIMacro_BuildData.do merges everything else
* onto this file; meanwks -> logmeanwks -> diff_logmeanwks is the treatment.
*
* INPUTS: county-pair-list.txt (border county-pair list, comma-separated;
*   county 30113 appears in the list but has no BLS LAUS data and is dropped);
*   LAUS/Output/NewLAUSData2014_final.dta (step 2).
* OUTPUT: NewLAUSBorderData2014_final24Nov16.dta (N=703,200; one-county pairs
*   dropped; pair_id_numeric + county_index identifiers added).
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

insheet using "${rawdata}/county-pair-list.txt", comma
rename county fipsnumeric
rename countypair_id pair_id

gen fipsstate = floor(fipsnumeric/1000)
bys pair_id: egen st_min = min(fipsstate)
bys pair_id: egen st_max = max(fipsstate)
drop if st_max ==st_min
drop st_min st_max fipsstate


expand 300
egen pair_id_county = group(pair_id fipsnumeric)
sort pair_id_county
generate firstob=1 if pair_id_county!= pair_id_county[_n-1]
gen time=1 if firstob
replace time=time[_n-1]+1 if firstob!=1

gen year    = 1990 + floor((time-1)/12)
gen month   = mod(time-1,12)+1
gen quarter = floor((month-1)/3)+1
drop time

sort year month fipsnumeric
merge m:1 year month fipsnumeric using "${rawdata}/LAUS/Output/NewLAUSData2014_final.dta"
*For some reason there is county with code 30113 in county-pair-list.txt that does
* not have a matching fips code in BLS data. It has _merge==1.
drop if _merge==1
drop if _merge==2
drop _merge

// Generate a numeric identifier for pairs
sort pair_id fipsnumeric year month
by pair_id: gen temp=_n==1
gen temp2=sum(temp)
ren temp2 pair_id_numeric
la var pair_id_numeric "Numeric ID for Pairs"
drop temp
tab pair_id_numeric

sort pair_id_numeric year month fipsnumeric
by pair_id_numeric year month: gen county_index=_n
la var county_index "Index of the county in the border county pair. Takes on 1 or 2"

** We need one county to be in NC, which means we should throw out those with only one obs.
bys pair_id_numeric year month: gen county_count=_N
drop if county_count==1

gen quarter_index=4*(year-2005)+quarter

drop cbsa* insamplemsa firstob county_count
order pair_id pair_id_numeric fipsnumeric fipsstate year ///
	quarter month quarter_index meanwks

save "${rawdata}/NewLAUSBorderData2014_final24Nov16", replace
