* ---------------------------------------------------------------------------
* 1c_QCEW_County_2014.do  ->  QCEW_County_2014_{total,private}.dta
* 2014 county QCEW monthly employment + weekly wages (q1-q3 vintage), total and
* private, that 3_MergeFullQCEW_2014_Q4 appends as the 2014 refresh.
*
* SOURCE (provided raw, QCEW/): `2014.q1-q3 10 Total, all industries.csv`
*   (BLS QCEW county file; own_code 0 = total, 5 = private).
* OUTPUT: QCEW_County_2014_total.dta + QCEW_County_2014_private.dta,
*   keyed fipsnumeric year month.
* ---------------------------------------------------------------------------
clear all
set matsize 11000
set maxvar 30000
set more off
do "config.do"
local RAW "${rawdata}/QCEW"

foreach s in total private {
    if "`s'"=="private" local own = 5
    else                local own = 0

    clear
    insheet using "`RAW'/2014.q1-q3 10 Total, all industries.csv", comma

    keep if agglvl_code == 70 | agglvl_code==71
    keep if size_code==0
    keep if own_code==`own'

    destring area_fips, replace
    gen fipsnumeric=area_fips
    drop if fipsnumeric > 56000

    forvalues x=1/3 {
        gen emp`x'=month`x'_emplvl
    }
    rename qtr quarter
    keep fipsnumeric year quarter emp* total_qtrly_wages avg_wkly_wage
    reshape long emp, i(fipsnumeric quarter) j(month)
    replace month=(quarter-1)*3+month

    save "${rawdata}/QCEW_County_2014_`s'", replace
}
