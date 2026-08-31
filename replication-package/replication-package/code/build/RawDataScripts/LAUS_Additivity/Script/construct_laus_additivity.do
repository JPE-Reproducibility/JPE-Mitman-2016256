drop _all
* Raw: BLS LAUS additivity ratios (additivity_ratios_2005-13.csv ships in ../Raw).
cd ${code}/build/RawDataScripts/LAUS_Additivity/Raw

insheet using additivity_ratios_2005-13.csv, clear

ren st_fips fipsstate
keep fipsstate year month empratio unempratio

cap mkdir "${code}/build/RawDataScripts/LAUS_Additivity/Output"
cd ${code}/build/RawDataScripts/LAUS_Additivity/Output
sort fipsstate year month
save additivity, replace
