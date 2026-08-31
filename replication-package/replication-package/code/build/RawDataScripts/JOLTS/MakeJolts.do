clear

* Raw: BLS JOLTS aggregate separations (jolts.csv ships in this folder).
cd ${code}/build/RawDataScripts/JOLTS
insheet using "jolts.csv", clear

rename v1 jolts_agg_seprate_m
rename v2 year
rename v3 month
rename v4 quarter

replace jolts_agg_seprate_m=jolts_agg_seprate_m/100

bys year quarter: egen jolts_agg_seprate_q=sum(jolts_agg_seprate_m)

replace jolts_agg_seprate_q=. if year==2000

su quarter

save "${rawdata}/jolts2013.dta", replace
