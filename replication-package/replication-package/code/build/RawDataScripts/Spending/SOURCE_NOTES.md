# Spending — ARRA (Recovery Act) county award spending

**Producer:** `Make_SpendingData.do` → `spending_data.dta`

**Sources (public, SpendingData/):**
- `cumulativenationalsummary_feb17_2009_dec31_2012.csv` — Recovery.gov *Cumulative
  National Summary* of ARRA awards, Feb 17 2009 – Dec 31 2012 (one row per award:
  `local_amount`, place-of-performance ZIP `pop_postal_cd`, fiscal year/quarter).
  Recovery.gov was decommissioned; the extract is redistributed here (and archival copies
  exist via web.archive.org).
- `ZiptoCounty.csv` — Missouri Census Data Center *geocorr* ZCTA→county crosswalk with
  population allocation factors (`afact`).

**What it builds:** award dollars summed by ZIP × fiscal quarter, allocated to counties in
proportion to `afact`, fiscal quarters mapped to calendar quarters via the mid-quarter
month → `awardamount` keyed `fipsnumeric year quarter`. The build merges it on county ×
quarter; `awardamount` → `logawardamount` (missing→0) → `diff_logawardamount(_gdp)` = the
"Stimulus (GDP)" control in the controls IFE experiment (Table 1 Col 10) and
`Table1_OLS_Controls`.

**Deterministic crosswalk numbering:** the producer numbers the expanded crosswalk with
`by zcta5 county afact: gen fiscal_year=_n`. Including `county` in the by-group matters
because numbering on `zcta5 afact` alone is nondeterministic when two counties in a zip
share the same `afact` (8,650 such groups): under that grouping Stata's unstable sort breaks
the tie differently from run to run and silently drops county-year allocations. With
`(zcta5, county)` each crosswalk row is unique, so every county receives all 4 years × 4
quarters and the allocation is the same on every run. The resulting county-quarter award
dollars produce a controls-IFE benefits coefficient of 0.0487 and a stimulus control of
−0.0002.
