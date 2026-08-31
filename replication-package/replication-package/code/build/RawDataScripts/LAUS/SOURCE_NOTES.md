# LAUS — county border-pair panel + state SA employment

Two chains share this folder (and the raw extracts in `data/raw/LAUS/`):

**County chain (steps 1–3)** → `NewLAUSBorderData2014_final24Nov16.dta`, THE core input
of the main build (the balanced border-county-pair monthly panel 1990–2014 carrying the
LAUS unemployment block and `meanwks`, the benefits treatment variable):

1. `1_construct_laus_2014.do` — five raw BLS LAUS county extracts
   `ladata0CurrentU{90-94,95-99,00-04,05-09,10-14}.txt` (post-2014-redesign vintage,
   20-char series_id) → `LAUS/Output/laus_2014_final.dta` (N=965,460).
2. `2_MakeNewLAUSDataSet.do` — adds state aggregates and the leave-out state unemployment
   rate; merges `Fullbenefits_MeanWks_Update.dta` (a **provided** benefit-weeks
   intermediate, state × month `meanwks`) with the 2014 statutory patches inline
   → `LAUS/Output/NewLAUSData2014_final.dta`.
3. `3_MakeNewLAUSBorderDataSet24Nov16.do` — crosses `county-pair-list.txt` (border
   county-pair list) with 1990–2014 months, merges step 2, builds pair identifiers
   → `NewLAUSBorderData2014_final24Nov16.dta` (N=703,200).

**State chain (steps 4–5)** → `StateEmp2014rev.dta` (state monthly SA employment, used for
`prod_all` = state GDP per worker):

4. `4_construct_laus_state_sa_pre.do` — raw `ladata3AllStatesS.txt` (same download batch,
   state series) → `LAUS/Output/laus_state_sa_pre.dta` (N=24,336, 1976–2014).
5. `5_Make_StateEmp2014rev.do` — keeps `fipsstate year month state_e_sa_pre`
   → `StateEmp2014rev.dta`.

**Placebo state rate panels (steps 6–7)** → `laus_state_sa.dta` + `laus_state_u.dta`
(state monthly unemployment rates, SA + unadjusted, the placebo-benefit extension triggers
in `Make_PlaceboWeeksData.do`):

6. `6_construct_laus_state_sa.do` — raw `LAUS/RevisedData/ladata3AllStatesS.txt`
   (**December-2015 revised download**, 1976–2015 — the 2015 LAUS re-benchmark revised the
   whole history, so this is a different vintage from the Sept-2014 batch; both ship)
   → `laus_state_sa.dta`.
7. `7_construct_laus_state_u.do` — raw `LAUS/RevisedData/ladata2AllStatesU.txt` (same
   Dec-2015 vintage) → `laus_state_u.dta`.

**State quarterly unemployment (step 8)** → `StateQuarterlyU.dta` (for
`analysis/TableA2.do`, the Hall-style alternative endogeneity test):

8. `8_Make_StateQuarterlyU.do` — raw `LAUS/ladata2AllStatesU.txt` (the **January-2015
   pre-redesign** extract, NOT the RevisedData vintage) → monthly
   `LAUS/Output/laus_state_u_preredesign.dta`, then a **day-weighted** quarterly collapse:
   the daily benefit-weeks file is merged (1:m on state-month) before collapsing, so quarters
   in the daily file's coverage (2002+) are day-weighted means of the monthly values and
   plain 3-month means elsewhere. The shipped file additionally carries all-missing 1974–75
   padding and excludes Puerto Rico — both irrelevant to TableA2 (it drops unmatched rows and
   uses 2007 only).

**Source (public):** U.S. Bureau of Labor Statistics, Local Area Unemployment Statistics
(https://www.bls.gov/lau/), September-2014 download (post-redesign revision). The state
file here is a *different* extract/format from `BLS_State/la.data.3.AllStatesS` (2013-06-22
vintage, 13-char series_id) used by `BLS_State/Make_StateEmp.do` — both are needed.

**Note:** the state chain produces `state_e_sa_pre` for every overlapping state-month; the
shipped `StateEmp2014rev.dta` additionally carries 1975/2015 rows and one extra state, all
outside the 1990–2014 panel and dropped by the build's merge, so they do not affect any
consumed observation.

**Vintage note:** LAUS is revised over time; only the archived extracts redistributed here
reproduce the published numbers. Three vintages ship: the September-2014 county/state batch
(steps 1–5), the January-2015 pre-redesign state unadjusted extract (step 8), and the
December-2015 revised state extracts (`RevisedData/`, steps 6–7).
