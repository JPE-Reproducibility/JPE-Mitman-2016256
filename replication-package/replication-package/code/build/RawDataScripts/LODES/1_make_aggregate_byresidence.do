* ---------------------------------------------------------------------------
* 1_make_aggregate_byresidence.do  ->  aggregate_byresidence.dta
* Derives aggregate_byresidence from commuter_countyFlows (the one provided LODES
* intermediate), so it is NOT an independent provided input. Run before
* LODES_match_to_pairs_v6.do.
*
* commuter_countyFlows.dta (year h_cty w_cty workers) = county-to-county commuter flows
* from the public Census LEHD LODES origin-destination data (block OD aggregated to
* county). It is shipped as a provided intermediate: the block-level OD raw and the R
* aggregation that produced it are not available, but the file is derived entirely from
* public Census LODES OD.
*
* aggregate_byresidence is just commuter_countyFlows aggregated to the residence county
* (in-county vs out-of-county workers) plus the LODES-coverage flags. The flags are
* state-year-level and mark the known LODES gaps (no LODES for AZ/AR/MS in the earliest
* years, DC through 2009, WY 2014-15) and their neighbors; encoded here as documented
* constants. (code/analysis/Mobility_LODES.do does not use the flags; they are carried only.)
* ---------------------------------------------------------------------------
clear all
set more off

global LI "${rawdata}"

use "${LI}/commuter_countyFlows.dta", clear
gen byte _in = (h_cty==w_cty)
bys year h_cty: egen in_county_workers  = sum(workers*_in)
bys year h_cty: egen _tot               = sum(workers)
gen out_county_workers = _tot - in_county_workers
bys year h_cty: keep if _n==1
keep year h_cty in_county_workers out_county_workers
gen pct_incounty  = 100*in_county_workers /(in_county_workers+out_county_workers)
gen pct_outcounty = 100*out_county_workers/(in_county_workers+out_county_workers)
gen STATE = floor(h_cty/1000)

* LODES-coverage flags (state x year), documented constants:
gen fl_miss = 0
replace fl_miss=1 if (STATE==4 & inlist(year,2002,2003)) | (STATE==5 & year==2002) ///
   | (STATE==11 & inrange(year,2002,2009)) | (STATE==28 & inlist(year,2002,2003)) ///
   | (STATE==56 & inlist(year,2014,2015))
gen fl_neighbor = 0
replace fl_neighbor=1 if (STATE==1 & inlist(year,2002,2003)) | (STATE==5 & inlist(year,2002,2003)) ///
   | (STATE==6 & inlist(year,2002,2003)) | (STATE==8 & inlist(year,2002,2003,2014,2015)) ///
   | (STATE==12 & inlist(year,2002,2003)) | (STATE==16 & inlist(year,2014,2015)) ///
   | (STATE==22 & inlist(year,2002,2003)) | (STATE==24 & inrange(year,2002,2009)) ///
   | (STATE==28 & year==2002) | (STATE==29 & year==2002) | (STATE==30 & inlist(year,2014,2015)) ///
   | (STATE==31 & inlist(year,2014,2015)) | (STATE==32 & inlist(year,2002,2003)) ///
   | (STATE==35 & inlist(year,2002,2003)) | (STATE==40 & year==2002) | (STATE==46 & inlist(year,2014,2015)) ///
   | (STATE==47 & inlist(year,2002,2003)) | (STATE==48 & year==2002) ///
   | (STATE==49 & inlist(year,2002,2003,2014,2015)) | (STATE==51 & inrange(year,2002,2009))

order STATE year h_cty in_county_workers out_county_workers pct_incounty pct_outcounty fl_miss fl_neighbor
sort h_cty year
save "${LI}/aggregate_byresidence", replace
