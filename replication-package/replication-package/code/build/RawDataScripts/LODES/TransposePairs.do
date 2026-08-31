use "${rawdata}/county_pairs.dta", clear

gen county_index=1

 save "${rawdata}/county_pairs_1.dta", replace
drop county_index 
 
gen temp1=w_cty
replace w_cty=h_cty
replace h_cty=temp1
replace temp1=w_st
replace w_st=h_st
replace h_st=w_st
gen county_index=2
drop temp1
rename pair_id_numeric pair_id_numeric2
rename county_index	county_index2
 save "${rawdata}/county_pairs_2.dta", replace
