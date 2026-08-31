# housing_elasticity — Saiz land-supply instruments

`housing_elasticity.dta` (`fipsnumeric elasticity WRLURI`, time-invariant, 965 counties)
is merged by the main build (`MakeDataSetsMainPaper_v5_newvac.do`, `merge m:1 fipsnumeric`).

## What it feeds
`MakeDataControls.do` builds `diff_elas` (from `elasticity`) and `diff_wharton` (from
`WRLURI`) — the **excluded instruments** for the house-price term (`diff_fhfa_lev`) in the
**Col-3 IV-GLS** of `tab:Endog_Vars` (`code/analysis/Endog_Vars.do`:
`... (diff_fhfa_lev = diff_elas diff_wharton)`). So this input is load-bearing for the IV.

## Source (provided, citable raw)
- **`HOUSING_SUPPLY.dta`** — the MSA-level elasticity / WRLURI file from the replication kit for

  > Saiz, A. (2010). "The geographic determinants of housing supply." *Quarterly Journal of
  > Economics*, 125(3), 1253–1296.
  > kit: https://drive.google.com/uc?id=1RnTT3f6w2LHjH7iPKnXqlTTkeHeMQ8ea&export=download

  keyed by `msanecma` (old MSA/NECMA/PMSA codes).
- **`cbsa_msanecma.dta`** (msanecma → CBSA) and **`cbsa_county.dta`** (CBSA → county FIPS) —
  public Census geography crosswalks.

All three ship in `data/raw/`.

## Producer
**`Make_Saiz_Elasticity.do`**:
`HOUSING_SUPPLY` ⋈ `cbsa_msanecma` → one MSA per CBSA → ⋈ `cbsa_county` → county-level
`elasticity`/`WRLURI`.

**Dedup pin.** Six combined metros map more than one old MSA/PMSA (with different Saiz
elasticities) to a single CBSA: Dallas–Fort Worth (19100), Miami–Fort Lauderdale–West Palm
Beach (33100), New York–Newark–Jersey City (35620), Philadelphia–Camden–Wilmington (37980),
San Francisco–Oakland (41860), Seattle–Tacoma (42660). The original `bys cbsa_code: keep if
_n==1` picked one order-dependently (Stata sort tie-break — not a consistent rule across the
six). The producer pins each to the `msanecma` the shipped file selected (Dallas, West Palm
Beach, Jersey City, Wilmington, San Francisco, Seattle), so it reproduces the published
instrument exactly. All other CBSAs have a single MSA row.

