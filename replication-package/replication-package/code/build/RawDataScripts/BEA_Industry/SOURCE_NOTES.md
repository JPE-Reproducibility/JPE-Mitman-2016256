# BEA_Industry — county employment by NAICS industry

**Producer:** `Make_IndustryShares.do` → `bea_industry_shares.dta`

**Source (public):** U.S. Bureau of Economic Analysis, Regional Economic Information System,
table **CA25N**, "Total full-time and part-time employment by NAICS industry," county level.
Archive `lapi1113-8/` — one CSV per state (`CA25N_<ST>.csv`), plus aggregate files
(`_US`/`_MSA`/`_MDIV`, skipped). Layout in `lapi1113-8/CA25N_def.xml`. Download:
https://www.bea.gov/ (Regional, CA25N).

**What it builds:** for each county, the sample-average (2005–2012) employment share of each
of the 19 private-nonfarm NAICS industries (BEA line codes 100…1900) in **private nonfarm
employment** (line 90). The build (`MakeDataSetsMainPaper`) then forms the **l2-distance**
between the two counties of each border pair from these average shares; the `industry_low`
flag marks the 50% of pairs with the most similar composition (l2 ≤ median over all border
pairs), which is **Column (6)** of `tab:Benefits_on_unemp`.

**Coverage note:** counties absent from CA25N (private-nonfarm employment entirely suppressed)
get a missing distance and are excluded from the Col-6 subsample. CSV columns flagged `(D)`
(BEA disclosure-suppressed) import as missing and are skipped industry-by-industry.
