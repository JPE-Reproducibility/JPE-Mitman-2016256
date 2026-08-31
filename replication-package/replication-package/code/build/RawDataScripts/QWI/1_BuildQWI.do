* ---------------------------------------------------------------------------
* 1_BuildQWI.do  ->  QWI_VintageQ32014.dta   (Census LEHD QWI, county x industry, long)
*
* STAGE 1 of the 3-stage QWI chain. Insheets the 48 raw per-state private-sector QWI
* extracts and appends them into one long file.
*
* Raw (public, Census LEHD QWI Explorer / LODES download, vintage 2014Q3):
*   one ZIP per state, "{ST}Priv.zip", each containing a single data CSV named with an
*   opaque hash (e.g. qwi_951745532ea54e0db105d5e0b6c343a3.csv) plus label_*.csv lookups.
*   Before running, unzip each to "{ST}Priv/" and rename the hashed CSV to "qwi_{ST}.csv":
*       for z in *Priv.zip; do st=${z%Priv.zip}; mkdir -p ${st}Priv; \
*         unzip -o $z -d ${st}Priv >/dev/null; \
*         mv ${st}Priv/qwi_*.csv ${st}Priv/qwi_${st}.csv; done
* ---------------------------------------------------------------------------
clear all
set more off

* raw QWI extracts live here
global QWIRAW "${rawdata}/QWI"
cd "${QWIRAW}"

foreach state in "AL" "AZ" "AR" "CA" "CO" "CT" "DE" "DC" "FL" "GA" "ID" "IL" "IN" "IA" "KS" "KY" "LA" "ME" "MD" "MI" "MN" "MS" "MO" "MT" "NE" "NV" "NH" "NJ" "NM" "NY" "NC" "ND" "OH" "OK" "OR" "PA" "RI" "SC" "SD" "TN" "TX" "UT" "VT" "VA" "WA" "WV" "WI" "WY" {
    * first run: extract the zipped LEHD download and normalize the hashed csv name
    cap confirm file "`state'Priv/qwi_`state'.csv"
    if _rc {
        cap mkdir "`state'Priv"
        cd "`state'Priv"
        unzipfile "../`state'Priv.zip", replace
        local hashed : dir "." files "qwi_*.csv"
        local h0 : word 1 of `hashed'
        if "`h0'" != "qwi_`state'.csv" {
            copy "`h0'" "qwi_`state'.csv", replace
            erase "`h0'"
        }
        cd ..
    }
    insheet using "`state'Priv/qwi_`state'.csv", clear
    drop periodicity seasonadj ind_level ownercode sex agegrp race ethnicity education firmage firmsize
    save "QWI`state'", replace
}

use "QWIAL", clear
foreach state in "AZ" "AR" "CA" "CO" "CT" "DE" "DC" "FL" "GA" "ID" "IL" "IN" "IA" "KS" "KY" "LA" "ME" "MD" "MI" "MN" "MS" "MO" "MT" "NE" "NV" "NH" "NJ" "NM" "NY" "NC" "ND" "OH" "OK" "OR" "PA" "RI" "SC" "SD" "TN" "TX" "UT" "VT" "VA" "WA" "WV" "WI" "WY" {
    append using "QWI`state'"
}

save "QWI_VintageQ32014", replace
