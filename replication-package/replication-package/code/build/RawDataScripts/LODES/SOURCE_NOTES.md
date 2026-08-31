# LODES commuter shares → `fraction_commuters_lite_flag.dta`

Cross-border commuter shares (Census LEHD LODES) for the mobility counterfactual in
`code/analysis/Mobility_LODES.do` (tab:Mobility_LODES). Variables: `fr_st_commuter`
(out-of-state commuter fraction), `fr_cty_commuter` (pair commuter fraction), `commuters`,
`emp_byresidence`, `fl_*`, `in_county_workers`, keyed `pair_id_numeric year county_index`.

## Producer chain (run in order)
1. **`1_make_aggregate_byresidence.do`** — derives `aggregate_byresidence` from
   `commuter_countyFlows` (in/out-of-county worker counts + the encoded LODES-coverage flags).
   So `aggregate_byresidence`/`aggregate_bywork` are NOT independent provided inputs.
2. **`LODES_match_to_pairs_v6.do`** (+ helper `TransposePairs.do`) — builds the border-county
   pair list from RevisionData (`UIMacro_RevisionData_2018_09_18`; the pair list is
   vintage-stable), computes out-of-state and pair commuter fractions from
   `aggregate_byresidence` + `commuter_countyFlows`, matches to the border pairs, and writes
   `fraction_commuters_lite_flag.dta`.

## The one provided intermediate: `commuter_countyFlows`
`commuter_countyFlows.dta` (year h_cty w_cty workers; 7.65 M rows, 2002-2015) is the
county-to-county commuter-flow file from the **public Census LEHD LODES** origin-destination
data (block OD aggregated to county). It ships as a provided intermediate: the block-level OD
raw and the R script that aggregated it were not preserved, but the file derives entirely from
public Census LODES OD. (`aggregate_byresidence` is derived from it — step 1; `aggregate_bywork`
is not used by the lite_flag chain.)


Locations in this archive: the provided `commuter_countyFlows.dta` and the chain's
outputs (`aggregate_byresidence`, `county_pairs*`, `fraction_commuters_lite_flag`) live in
`data/raw/`; the pair list is derived from the shipped border panel
(`NewLAUSBorderData2014_final24Nov16`).
