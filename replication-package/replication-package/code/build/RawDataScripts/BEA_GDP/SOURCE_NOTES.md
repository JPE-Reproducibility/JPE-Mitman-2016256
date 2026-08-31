# BEA_GDP — quarterly real GDP by state

**Producer:** `Make_BEA_GDP_State_Q.do` → `BEA_GDP_State_Q.dta`

**Source (public):** U.S. Bureau of Economic Analysis, prototype **quarterly GDP by state**
statistics, "Real GDP by state" component — `BEA_GDP/qgsp_all_R.csv` (July-2016 download;
GeoFIPS × industry wide, columns `2005Q1`–`2016Q1`; trailing footnote rows dropped).
Download: https://www.bea.gov/data/gdp/gdp-state (the quarterly GDP-by-state prototype was
released via the BEA interactive data application; `qgsp_all_R` = all industries, real).

**What it builds:** keeps `industryid` 1 ("All industry total") and 2 ("Private industries"),
reshapes to a `fipsstate` × quarter panel (50 states + DC + the 8 BEA regions, FIPS 91–98)
→ `state_gdp_all`, `state_gdp_priv` (millions of chained dollars), keyed `fipsstate year quarter`.
The build merges it on `fipsstate year quarter` and uses it for the state productivity controls
(`prod_all` = GDP per LAUS worker, `prod_priv` = private GDP per QCEW private worker,
`prod_all_qcew`) and the `diff_logstate_gdp_all` growth adjustment.

**Vintage note:** BEA revises GDP by state with every release; only the July-2016 extract
reproduces the published numbers.
