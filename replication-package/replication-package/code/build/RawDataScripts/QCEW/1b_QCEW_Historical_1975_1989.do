* ---------------------------------------------------------------------------
* 1b_QCEW_Historical_1975_1989.do  ->  QCEW_Historical_County_{total,private}.dta
* Pre-1990 county QCEW monthly employment + weekly wages, total (own_code 0) and
* private (own_code 5), built from the annual BLS QCEW county CSVs for 1975-1989.
* (The allhlcn high-level Excel files used by 1_construct_qcew_2015 only cover
* 1990 onward; this supplies the 1975-1989 history that 2_MergeFullQCEW appends.)
*
* SOURCE (provided raw, QCEW/): `{yyyy}.q1-q4 10 Total, all industries.csv`
*   (BLS QCEW county files, layout https://www.bls.gov/cew/about-data/downloadable-file-layouts.htm;
*   each file carries all ownership codes -- own_code 0 = total, 5 = private).
* OUTPUT: QCEW_Historical_County_total.dta + QCEW_Historical_County_private.dta,
*   keyed fipsnumeric year month (county-months 1975m1-1989m12).
* ---------------------------------------------------------------------------
clear all
set matsize 11000
set maxvar 30000
set more off
do "config.do"
local RAW "${rawdata}/QCEW"
cap mkdir "${rawdata}/QCEW/Output"

foreach s in total private {
    if "`s'"=="private" local own = 5
    else                local own = 0

    forvalues yr=1975/1989 {
        disp as text "QCEW historical `s' year=" as result `yr'
        clear
        insheet using "`RAW'/`yr'.q1-q4 10 Total, all industries.csv", comma

        keep if agglvl_code == 70 | agglvl_code==71      // county
        keep if size_code==0
        keep if own_code==`own'                          // 0 total / 5 private

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

        save "${rawdata}/QCEW/Output/QCEW_County_`yr'_`s'", replace
    }

    drop _all
    forvalues yr=1975/1989 {
        append using "${rawdata}/QCEW/Output/QCEW_County_`yr'_`s'"
        erase "${rawdata}/QCEW/Output/QCEW_County_`yr'_`s'.dta"
    }
    save "${rawdata}/QCEW_Historical_County_`s'", replace
}
