# Data and Code for: Unemployment Benefits and Unemployment in the Great Recession: The Role of Macro Effects

Marcus Hagedorn (University of Oslo), Fatih Karahan (Central Bank of the Republic of
Türkiye), Iourii Manovskii (University of Pennsylvania), and Kurt Mitman (CEMFI and IIES,
Stockholm University). *Journal of Political Economy*.

Contact for questions about this package: Kurt Mitman (kurt.mitman@iies.su.se).

---

## Overview

This archive contains the data and code that produce every table, figure, and inline
number in the paper (`code/tex/MacroElasticity_JPE_Rev3_1_I.tex`). The
Conference Board's proprietary **Help-Wanted OnLine (HWOL)** county/state vacancy series —
cannot be redistributed; the archive ships a clearly-labeled **public-data synthetic
stand-in** in its place (Section "Synthetic stand-in" below), so the entire pipeline runs
end-to-end without the confidential data. Exhibits that depend on the vacancy series are
therefore **demonstrative** as shipped; every other exhibit reproduces exactly. Section
"List of tables and programs" gives the exhibit-by-exhibit classification.

After a one-line path edit, `bash do_replication.sh` from the archive root runs the entire
replication (from-raw rebuild through the compiled paper) in roughly 10–15 hours on a
multi-core machine.

---

## Data Availability and Provenance Statements

All data used in the paper are **publicly available or redistributed in this archive**,
with one exception: the proprietary HWOL vacancy series (source 21 below). Every other
input ships in the archive — either as the raw extract actually downloaded (with the
build code that processes it, in `code/build/RawDataScripts/`) or as a provided
vintage-of-record intermediate where noted (this includes the authors' compilations of
administrative series, sources 18–19, which the authors are permitted to redistribute).
No data need to be downloaded to run the archive.

Several public sources are **vintage-stamped**: BLS revises LAUS, FHFA back-revises its
HPI, BEA revises GDP, and the Census Bureau rebases its population estimates. The archive
redistributes the archived extracts actually used — a current re-download would *not*
reproduce the published numbers — and each source entry below states the vintage and
access date. Where an exact access date was not recorded at download time, the date given
is inferred from the vintage stamps in the archive (file names, coverage end dates) and is
marked "inferred."

### Statement about Rights

- **Part 1 (right to use):** We certify that the authors of the manuscript have legitimate
  access to, and permission to use, all data employed in this manuscript. The public data
  were downloaded from the producing agencies' public dissemination channels under their
  respective terms of use; the published-archive files (sources 9 and 11, and the
  Dube-Lester-Reich county-pair list) were obtained from openly published replication
  archives; sources 18–19 are the authors' own compilations from DOL/ETA and state-agency
  records; and the HWOL data were obtained from The Conference Board under a research
  data-use agreement.
- **Part 2 (right to publish):** We certify that the authors have permission to
  redistribute every data file included in this archive. All included data are aggregate
  county-, state-, or national-level series produced by statistical agencies or published
  research archives; **no human-subjects microdata are involved**, and no IRB approval was
  required. The one licensed input (HWOL) is **excluded** from the archive because our
  agreement with The Conference Board does not permit redistribution; the synthetic
  stand-in shipped in its place was created by the authors from public data only and
  contains no HWOL information.

### License for Data

The derived and compiled data files in this archive are made available under a **Creative
Commons Attribution 4.0 International (CC BY 4.0)** license. Underlying U.S. government
data (BLS, Census, BEA, FHFA, DOL, USDA, Recovery.gov) are in the public domain;
redistributed third-party files (sources 9, 11, and 13, and the Dube-Lester-Reich
county-pair list) remain subject to their original terms. See `LICENSE.txt`.

### Details on each data source

Each entry states content, provenance, vintage, access date, and the files shipped. Formal
citations for every source are collected in the **References** section at the end of this
README; the same citations appear in the paper's bibliography. Per-input build mechanics
(file layouts, raw-source details, vintage notes) are additionally documented in the
`SOURCE_NOTES.md` inside each `code/build/RawDataScripts/<source>/` folder.

1. **U.S. Bureau of Labor Statistics, Local Area Unemployment Statistics (LAUS).**
   County and state unemployment, employment, and labor force. https://www.bls.gov/lau/.
   Public. Four archived extracts are redistributed:
   (i) county series `LAUS/ladata0CurrentU{90-94,…,10-14}.txt` and state series
   `LAUS/ladata3AllStatesS.txt` (accessed September 2014) → the core border-county panel
   `NewLAUSBorderData2014_final24Nov16` and `StateEmp2014rev`;
   (ii) `LAUS/ladata2AllStatesU.txt` (accessed January 2015, pre-redesign) → `StateQuarterlyU`;
   (iii) `LAUS/RevisedData/ladata{2AllStatesU,3AllStatesS}.txt` (accessed December 2015,
   revised) → `laus_state_sa`, `laus_state_u` (placebo triggers);
   (iv) `BLS_State/la.data.{2.AllStatesU,3.AllStatesS}` (accessed June 22, 2013) →
   `state_emp_quarterly`. Also the LAUS additivity ratios
   (`RawDataScripts/LAUS_Additivity/Raw/additivity_ratios_2005-13.csv`, BLS LAUS program,
   accessed circa 2014, inferred).

2. **U.S. Bureau of Labor Statistics, Job Openings and Labor Turnover Survey (JOLTS).**
   Aggregate job openings and separation rates. https://www.bls.gov/jlt/. Public.
   Accessed circa 2013 (inferred from the `jolts2013` vintage stamp). Raw extract
   `RawDataScripts/JOLTS/jolts.csv` → `jolts2013` (also the basis of the synthetic-vacancy
   stand-in).

3. **U.S. Bureau of Labor Statistics, Quarterly Census of Employment and Wages (QCEW).**
   County monthly employment and weekly wages, total and private, 1975–2015.
   https://www.bls.gov/cew/. Public. Accessed circa 2015–2016 (inferred; the newest raw
   file is the 2015 county release). Raw county "high-level" Excel files
   (`QCEW/{yyyy}_all_county_high_level/`, 1990–2015), annual county CSVs 1975–1989, and
   the `2014.q1-q3` refresh CSV → `QCEWAllYears_2014Q4` (built end-to-end).

4. **U.S. Census Bureau, Longitudinal Employer-Household Dynamics, Quarterly Workforce
   Indicators (LEHD QWI).** County worker flows, employment, and earnings by sector;
   2014Q3 release vintage. https://lehd.ces.census.gov/data/. Public. Accessed
   September 18, 2018 (inferred from the archive's vintage stamp). Raw per-state
   private-sector extracts (`QWI/{ST}Priv.zip`, 48 states) → `QWI_2018_09_18_t` and (with
   the LAUS border panel) `bartik_shocks`.

5. **U.S. Census Bureau, LEHD Origin-Destination Employment Statistics (LODES).**
   County-to-county commuter flows, 2002–2015. https://lehd.ces.census.gov/data/lodes/.
   Public. Accessed circa 2017–2018 (inferred). Provided county-aggregated
   origin–destination file `commuter_countyFlows.dta` (the block-level OD raw and its
   aggregation script were not preserved; the file derives entirely from public LODES OD
   data) → `fraction_commuters_lite_flag`.

6. **U.S. Bureau of Economic Analysis, prototype quarterly GDP by state.** Real GDP by
   state ("all industry total" and "private industries"), 2005Q1–2016Q1.
   https://www.bea.gov/data/gdp/gdp-state. Public. Accessed July 2016.
   Raw `BEA_GDP/qgsp_all_R.csv` → `BEA_GDP_State_Q`.

7. **U.S. Bureau of Economic Analysis, Regional Economic Accounts, table CA25N.** County
   full- and part-time employment by NAICS industry, November 2013 local-area release.
   https://www.bea.gov/data/employment/employment-county-metro-and-other-areas. Public.
   Accessed circa November 2013 (inferred from the `lapi1113-8` release-archive name).
   Raw per-state CSVs (`lapi1113-8/CA25N_*.csv`) → `bea_industry_shares` (the Column-6
   industry-similarity subsample).

8. **Federal Housing Finance Agency, House Price Index** (annual county developmental
   index, all-transactions). https://www.fhfa.gov/data/hpi. Public. Accessed July 26,
   2018 (inferred from the vintage-of-record stamp). Raw `HPI_AT_BDL_county.xlsx` (2018
   vintage; FHFA back-revises the full index with each release, so a current re-download
   will not match) → `NewFHFA_2018_07_26`.

9. **IRS Statistics of Income county income (via a published replication archive).**
   County adjusted gross income 2004–2012, taken from the county net-worth panel
   (`networth_all_counties_2004q1_2012q4.dta`) of the published replication archive for
   Kaplan, Mitman, and Violante (2020), *Journal of Public Economics*. Public archive;
   access date not recorded (the vintage-of-record archive file ships here).
   → `IRSEquifax` (trimmed to `agi`).

10. **Federal Reserve Bank of New York Consumer Credit Panel / Equifax.** County household
    debt-to-income (public-use county file, `household-debt-by-county.csv`).
    https://www.newyorkfed.org/microeconomics/databank.html. Public. Accessed circa 2018
    (inferred; download date not recorded). → `county_debt`.

11. **Saiz (2010) land-supply elasticity and Wharton regulation index.** MSA-level housing
    supply elasticity and WRLURI from the published replication archive of Saiz (2010),
    *Quarterly Journal of Economics* (the WRLURI originates from Gyourko, Saiz, and
    Summers 2008). Public archive; access date not recorded (the time-invariant archive
    file ships here). Raw `HOUSING_SUPPLY.dta` + public Census geography
    crosswalks `cbsa_msanecma.dta`, `cbsa_county.dta` → `housing_elasticity` (the
    tab:Endog_Vars IV instruments).

12. **U.S. Census Bureau, Quarterly Summary of State and Local Government Tax Revenue.**
    State quarterly tax revenue by type (property, general sales, income, corporate,
    total), Table 3. https://www.census.gov/programs-surveys/qtax.html. Public. Accessed
    circa 2013 (inferred from the extract's 2013Q1 terminal quarter). Provided long-form
    extract `IouriiStateTax.dta` → `StatePolicies_taxes`.

13. **State business-policy indices** (annual/quarterly 2005–2012, raw CSVs in
    `RawDataScripts/StatePolicies/`): Small Business & Entrepreneurship Council, *Small
    Business Survival/Policy Index* (`sbsi`); Tax Foundation, *State Business Tax Climate
    Index* (`sbtc`); Beacon Hill Institute, *State Competitiveness Report* score (`bhi`);
    and a judicial-foreclosure-state classification compiled by the authors from state
    foreclosure statutes (`judicial`). Public. Accessed circa 2013 (inferred).
    → `StatePolicies_indices`.

14. **U.S. Department of Agriculture, Economic Research Service, SNAP Policy Database.**
    State-month SNAP policy indicators (broad-based categorical eligibility / asset test).
    https://www.ers.usda.gov/data-products/snap-policy-data-sets. Public. Accessed 2018
    (inferred from the archive's vintage stamps). Raw
    `RawDataScripts/SNAP/SNAP_Policy_Database.csv` →
    `SNAP_Policy_Database_Processed_2018_premerge`.

15. **Recovery.gov, Cumulative National Summary of ARRA awards** (Feb 17, 2009 –
    Dec 31, 2012; accessed circa 2013, inferred; Recovery.gov has been decommissioned —
    the extract is redistributed here, and archival copies exist via web.archive.org) and
    **Missouri Census Data Center, geocorr** ZCTA→county crosswalk with population
    allocation factors (https://mcdc.missouri.edu/applications/geocorr.html; accessed
    circa 2013, inferred). Public.
    Raw `SpendingData/{cumulativenationalsummary_feb17_2009_dec31_2012.csv,ZiptoCounty.csv}`
    → `spending_data` (the stimulus-spending control).

16. **U.S. Census Bureau, Population Estimates Program.** Annual county resident
    population 2000–2011, **archived pre-rebase vintage** (provided as
    `population_age.dta`, trimmed to `popestimate`; the post-2010-census intercensal file
    differs by 1–3% from the vintage estimates the published results used).
    https://www.census.gov/programs-surveys/popest.html. Public. Accessed circa 2012
    (inferred). Feeds the LAUS imputation and the appendix endogeneity table.

17. **Shimer (2012) job-separation series.** Quarterly CPS-based separation rate,
    1948–2013, the published series accompanying Shimer (2012), *Review of Economic
    Dynamics*. Accessed circa 2013–2014 (inferred). Provided as `cpssep.dta`. Feeds the
    LAUS imputation.

18. **U.S. Department of Labor / state UI benefit policy (EB/EUC/TEUC weeks of
    eligibility).** Legislative trigger data compiled by the authors from DOL/ETA trigger
    notices (https://oui.doleta.gov/unemploy/trigger/) and state UI law; provided as the
    consolidated `benefit_weeks.dta` (the build's single weeks input), with two
    companions: `Fullbenefits_MeanWks_Update.dta` (LAUS Stage-1 chain) and
    `FullFinal_AllYears-Daily.dta` (daily series, used by the benefit-duration maps;
    byte-identical to the corresponding file in the authors' published AEA replication
    archive openICPSR-205681, which documents the EB/EUC/TEUC trigger construction).

19. **County UI continuing-claims records** (administrative claims data compiled by the
    authors from state workforce agencies / U.S. DOL ETA; per-county claims series in
    `claims/`, `claims_quarterly.dta`) → the job-finding back-out `quarterly_f` and the
    imputation inputs. **DOL/ETA UI tax receipts** (Unemployment Insurance Financial Data
    Handbook, ET Handbook 394; https://oui.doleta.gov/unemploy/hb394.asp), provided as
    `UI_Tax_Data_Final.dta` → `UI_Tax_Data_Fips` (built by `RawDataScripts/BuildUITax.do`;
    the `ui_tax_rate` ingredient of the QWI/QCEW wage measures).

20. **U.S. Census Bureau geography:** Gazetteer county centroids (`LatLongData.dta`),
    OMB/Census CBSA delineation (county→CBSA crosswalk, `cbsacode_xwalk.dta`), and the
    2025 county cartographic boundary shapefile (`cb_2025_us_county_20m.zip`, for the
    maps). https://www.census.gov/geographies/. Public.

21. **The Conference Board, Help-Wanted OnLine (HWOL)** — county and state job-vacancy
    series. **PROPRIETARY — NOT INCLUDED IN THIS ARCHIVE**; see the next subsection.

Also: the cross-state contiguous **border county-pair list** (`county-pair-list.txt`) from
the published data archive of Dube, Lester, and Reich (2010), *Review of Economics and
Statistics*.

### Confidential data: HWOL — access procedure, preservation, and codebook

**What it is.** The Conference Board's Help-Wanted OnLine (HWOL) Data Series measures the
universe of unique online job vacancies (roughly 16,000 job boards and online newspaper
editions, de-duplicated by TCB), monthly from May 2005. The paper uses (i) a county-month
extract of total and new vacancies and (ii) a state-month total-vacancy series.

**How we obtained it.** The authors obtained the HWOL extracts directly from The
Conference Board under a research data-use agreement, in the same way as Şahin, Song,
Topa, and Violante (2014, *American Economic Review*; see their replication archive,
openICPSR-112705, whose HWOL input is the same product). Our agreement does **not**
permit redistribution of the data in any form.

**How to obtain access (all necessary steps):**

1. Contact The Conference Board (https://www.conference-board.org/; general data
   inquiries via the website contact form or +1 212 759 0900), referencing the
   *Help-Wanted OnLine (HWOL) Data Series* and requesting the historical **county-level
   monthly vacancy extracts** (total vacancies and new vacancies by county FIPS) and
   **state-level monthly totals** for 2005–2015.
2. Execute The Conference Board's research data-use agreement. Terms (fees, permitted
   use, duration) are set by TCB and may depend on institutional affiliation; the
   agreement we signed prohibits redistribution of the raw series.
3. Once the extracts are received, verify them against the codebook below, place the two
   files where `code/config.do` points (`${vacfile}`, `${statefile}`), and re-run — see
   "Synthetic stand-in" below for the exact swap-in mechanics.

**Preservation and support for replication checks.** The authors commit to preserving
their licensed HWOL extracts, together with all code in this archive, for **no fewer than
five years following publication** of the paper, and to providing reasonable assistance to
requests for clarification and replication, per JPE policy. Because the license bars any
transfer of the data, the authors will additionally, **on request from the Data Editor or
from researchers, re-run any of the vacancy-gated exhibits on the licensed HWOL data and
share the resulting estimates/output** (which disclose no raw HWOL observations).

**Codebook for the confidential files.** The synthetic stand-ins in `synthetic-data/`
have exactly the same file layout, variable names, and storage types as the licensed
files, so they double as a structural template: a replicator who obtains HWOL access can
verify they have a substantially similar dataset by matching this schema.

`new_vac_april2017.dta` (county file; licensed original accessed April 2017; synthetic
stand-in `new_vac_synthetic.dta`): county-month panel, ~1,134 border counties, 2005–2014.

| variable | type | description |
|---|---|---|
| `fipsnumeric` | double | County FIPS code (numeric) |
| `year` | float | Calendar year |
| `month` | float | Calendar month (1–12) |
| `total_vacancies_county` | float | Total unique active online job vacancies in the county-month (HWOL "stock") |
| `total_newvacancies_county` | float | Vacancies first observed in the county-month (HWOL "new ads" flow) |

`StateMonthlyBorderData_2018_07_25.dta` (state file; licensed original accessed July 25,
2018; synthetic stand-in `StateMonthlyBorderData_synthetic.dta`): state-month panel of
border-segment states, 2006–2015, 90 variables. **Only two columns are HWOL:**
`total_vacancies_state` and `total_newvacancies_state` (state totals of the above). All
other columns (state LAUS unemployment/employment, QCEW state employment and wages, weeks
of benefits, population, state GDP) are public series that the synthetic version rebuilds
from the public inputs in this archive.

---

## Dataset list

All files below ship in the archive except the two HWOL originals (last row).

| File(s) — in `data/raw/`, except rows prefixed `RawDataScripts/`, which live in `code/build/RawDataScripts/` | Source (entry above) | Provided |
|---|---|---|
| `LAUS/`, `BLS_State/`, `RawDataScripts/LAUS_Additivity/` | 1. BLS LAUS | Yes (raw extracts) |
| `RawDataScripts/JOLTS/jolts.csv` → `jolts2013.dta` | 2. BLS JOLTS | Yes |
| `QCEW/` (1975–2015 raw) → `QCEWAllYears_2014Q4.dta` | 3. BLS QCEW | Yes |
| `QWI/{ST}Priv.zip` (48 states) | 4. Census LEHD QWI | Yes |
| `commuter_countyFlows.dta` | 5. Census LODES | Yes (provided intermediate) |
| `BEA_GDP/qgsp_all_R.csv` | 6. BEA state GDP | Yes |
| `lapi1113-8/CA25N_*.csv` | 7. BEA CA25N | Yes |
| `HPI_AT_BDL_county.xlsx` | 8. FHFA HPI | Yes (2018 vintage of record) |
| `networth_all_counties_2004q1_2012q4.dta` | 9. IRS SOI (via KMV archive) | Yes |
| `RawDataScripts/CountyDebt/household-debt-by-county.csv` | 10. NY Fed CCP/Equifax | Yes |
| `HOUSING_SUPPLY.dta`, `cbsa_msanecma.dta`, `cbsa_county.dta` | 11. Saiz (2010) archive | Yes |
| `IouriiStateTax.dta` | 12. Census QTAX | Yes |
| `RawDataScripts/StatePolicies/*.csv` | 13. Business-policy indices | Yes |
| `RawDataScripts/SNAP/SNAP_Policy_Database.csv` | 14. USDA SNAP Policy Database | Yes |
| `SpendingData/` | 15. Recovery.gov ARRA + geocorr | Yes |
| `population_age.dta` | 16. Census population estimates | Yes (pre-rebase vintage) |
| `cpssep.dta` | 17. Shimer (2012) series | Yes |
| `benefit_weeks.dta`, `Fullbenefits_MeanWks_Update.dta`, `FullFinal_AllYears-Daily.dta` | 18. DOL UI trigger data (authors' compilation) | Yes |
| `claims/`, `claims_quarterly.dta`, `UI_Tax_Data_Final.dta` | 19. County UI claims; DOL ETA tax receipts | Yes |
| `LatLongData.dta`, `cbsacode_xwalk.dta`, `cb_2025_us_county_20m.zip`, `state_codes.dta` (state FIPS/abbreviation crosswalk) | 20. Census geography | Yes |
| `county-pair-list.txt` | Dube-Lester-Reich (2010) archive | Yes |
| `synthetic-data/new_vac_synthetic.dta`, `synthetic-data/StateMonthlyBorderData_synthetic.dta` | Synthetic stand-in for 21 (authors) | Yes |
| *HWOL originals:* `new_vac_april2017.dta`, `StateMonthlyBorderData_2018_07_25.dta` | 21. Conference Board HWOL | **No** (proprietary) |

`data/processed/` is **generated by the run** (≈5 GB) and is not shipped; `output/` ships
empty and is populated by the run.

---

## Computational requirements

### Software Requirements

- **Stata/MP**, version 14 or later (the build and the `egen`-heavy steps assume MP; the
  seeded random draws use the mt64 generator, which is stable across Stata 14+). All
  required user-written commands install **automatically from SSC**: `code/config.do` —
  which every pipeline script sources — checks for and installs `regife` (interactive
  fixed effects), `reghdfe`, `ivreg2` (+ `ranktest`), `outreg2`, `binscatter`, `ftools`,
  `coefplot`, `tuples`, `hdfe`, and `mat2txt` on first run (an internet connection is
  needed once). No packages are bundled; `regife` is **not** redistributed — it loads
  from SSC like the rest. `config.do` also sets `scheme s2color` so regenerated figures
  match the published styling (Stata 18+ defaults to the newer `stcolor` scheme, which
  looks different).
- **MATLAB** (developed and tested on R2025b) for the factor model, block bootstrap, and
  the structural model. Point estimates are deterministic and reproduce across MATLAB
  versions; see "Controlled Randomness" for a version caveat affecting bootstrap
  p-values/standard errors only.
- **Python 3** for `code/tex/make_tables.py` (standard library only). The two map figures
  additionally need `geopandas` + `matplotlib` (any recent version; the driver skips the
  maps with a warning if geopandas is absent).
- A **TeX** distribution (pdflatex + bibtex) to compile the paper.

### Controlled Randomness

Every stochastic step in the pipeline is seeded; no step relies on an unseeded random
state. The seeds, in pipeline order:

| Where | Seed | What it controls |
|---|---|---|
| `code/build/Make_Synthetic_Vacancies.do:46` | `set seed 80539` | The persistent and transitory county deviations in the **synthetic vacancy** stand-in (`rnormal` draws). The synthetic files ship pre-generated, so driver runs do not depend on this seed. |
| `code/exporters/OutputDataSetsUIMacro_Scrambles.do:29` | `set seed 85237940` | Generation of the **200 scrambled county pairings** (placebo columns of Tables 1/A-3; `runiform` + sort). |
| `code/analysis/Endog_Bartik_Scrambles.do:49` | `set seed 85237940` | Re-generates the identical 200 scrambled pairings (same seed, same code, same deterministic pre-sort) for the per-scramble Bartik IV endogeneity test. |
| `code/analysis/Endog_Bartik.do:89` | `simulate …, seed(20180802)` | 200-rep cluster (border-segment) bootstrap for the Bartik endogeneity test. |
| `code/analysis/Imputed_Results.do:150` | `simulate …, seed(20180802)` | 200-rep cluster bootstrap for the three imputed-outcome columns of Table A-8 (seed reset at the start of each column). |
| `code/analysis/Mobility_LODES.do:160` | `simulate …, seed(12345)` | 200-rep cluster bootstrap for the LODES mobility regression (Table A-7). |
| `code/matlab/Factor_FrontEnd_*.m` (all 31 front-ends) | `seed=15` via `rand('seed',15)` | The **200-rep cluster (border-segment) block bootstrap** inside `RunPValsFactor_newbs_v4_nowks.m` for every factor-model experiment — all bootstrap p-values, percentiles, and standard errors in the IFE tables. |
| `code/matlab/RunMonteCarlo.m:5` | `rng('default')` (Mersenne Twister, seed 0) | The Monte Carlo data generation for Table A-2 (2,000 simulated panels × 9 error structures). |
| `code/matlab/Fig_InitialGuess.m` | `rng('default')` | The 1,000 random initial guesses in Figure A-3 (the estimation itself is deterministic). |

Notes:

- **Point estimates never depend on random draws.** The interactive-fixed-effects
  estimator, the entire data build, the LAUS imputation chain (a deterministic grid
  search), and the structural model (which loads fixed pre-drawn shock sequences from
  `code/model/Sequences_2018_07_30.mat`) contain no random calls. Randomness affects only
  bootstrap p-values/SEs, the scramble placebo distribution, and the Monte Carlo table.
- A few scripts contain legacy `set seed` boilerplate with no subsequent random call
  (e.g. `set seed 5` in `Imputed_Results.do:36`, `Mobility_LODES.do:31`, and the QCEW
  merge scripts); these are inert — the operative seeds are the ones tabulated above
  (Stata's `simulate, seed()` resets the RNG itself).
- **MATLAB version caveat.** The front-ends use the legacy `rand('seed',15)` interface,
  which puts the *global* stream into the old v4 generator; both `rand` and `randperm`
  in the bootstrap draw from it, so runs are exactly reproducible *on a given MATLAB
  version* (R2025b tested). Because MathWorks has changed `randperm`'s internal stream
  consumption across releases, bootstrap p-values/SEs can differ slightly on other MATLAB
  versions. `rng('default')` (Monte Carlo, Figure A-3) is stable across versions.
- Stata's mt64 generator makes all Stata draws stable across Stata 14+ regardless of OS.

### Memory, Runtime, and Storage Requirements

- **Runtime: ≈10–15 hours** sequentially on a modern multi-core machine, of which: the
  from-raw input rebuild ≈1.5 h; the 31 factor-model front-ends with 200-rep bootstraps
  ≈5–15 min each; the 200-pairing Scrambles runs ≈1–2 h; the Monte Carlo and the
  structural model most of the remainder. The Stata build itself takes minutes.
- **Storage:** the shipped archive is ≈3.5 GB uncompressed; the run generates ≈5 GB of
  master datasets in `data/processed/` plus result CSVs/figures in `output/` — budget
  **≈10 GB** free disk.
- **Memory:** 16 GB is comfortable for every step (the reproducibility check ran on a
  64 GB machine; nothing approaches that bound).

---

## Description of programs/code

```
.
├── README.md                ← this file (single point of documentation)
├── LICENSE.txt              ← code (BSD-3) and data (CC BY 4.0) licenses
├── do_replication.sh        ← ONE-FILE replication driver (runs everything below, in order)
├── code/
│   ├── config.do            single Stata path/scheme/seed configuration (sourced by every script)
│   ├── RunBuild.do          orchestrator: from-raw rebuild (Stage 1) + master datasets (Stage 2)
│   ├── build/               Stata build pipeline + RawDataScripts/ per-source producers
│   ├── exporters/           Stata: write per-pair QBLS text files for the MATLAB factor model
│   ├── matlab/              MATLAB: IFE factor model + block bootstrap (config.m = path config)
│   ├── analysis/            Stata/Python: final regressions, imputation, Missouri study, maps
│   ├── model/               MATLAB: structural model (calibration + validation) + Fig_StateU
│   └── tex/                 paper source, make_tables.py (assembles all table .tex), articles.bib
├── data/
│   ├── raw/                 public raw inputs + provided intermediates (see Dataset list)
│   └── processed/           built master datasets (GENERATED by the run; not shipped)
├── output/                  (GENERATED; ships empty) tables/, figures/, factor_results/, logs/
└── synthetic-data/          synthetic stand-in for the proprietary HWOL vacancy data
```

The driver `do_replication.sh` runs, in order: (1) the MATLAB job-finding back-out;
(2) `RunBuild.do` (from-raw rebuild + master datasets); (3) the factor-model exporters;
(4) all MATLAB factor-model front-ends + `ProcessQDK` + `RunMonteCarlo` +
`Fig_InitialGuess`; (5) the LAUS imputation chain; (6) the structural model +
`Fig_StateU`; (7) the final Stata analyses and figures; (8) the Python map figures;
(9) `make_tables.py` and the paper compile. Every Stata log is checked for errors as it
goes.

### License for Code

The code is licensed under a **BSD-3-Clause (Modified BSD) license**; see `LICENSE.txt`.

---

## Instructions to replicators

> **Setup (paths) — one edit.** Set this archive's location once: edit the `root` line at
> the top of `code/config.do` (Stata) and `code/matlab/config.m` (MATLAB). Every script
> derives `data/raw`, `data/processed`, `output/`, etc. from it — there are no other
> hard-coded paths.
>
> **One command.** After the path edit, `bash do_replication.sh` (from the archive root)
> runs the ENTIRE replication — from-raw input rebuild, master datasets, all factor-model
> estimations and bootstraps, imputation, structural model, analyses, figures, tables, and
> the compiled paper (≈10–15 hours sequentially; see the script header for prerequisites
> and the `STATA`/`MATLAB`/`PYTHON_GEO` environment overrides).
>
> **How to run pieces by hand.** Launch Stata with the working directory set to **`code/`**,
> then run any pipeline script by relative path (e.g. `do "build/UIMacro_BuildData.do"`);
> each script sources `config.do` itself. Run the MATLAB front-ends from **`code/matlab/`**
> (each calls `config`). Outputs land in `output/`; the per-pair QBLS handoff is
> regenerated into `output/factor_inputs/`.

Pipeline (one-way; each stage feeds the next):

1. **(optional) Rebuild raw-derived inputs from raw** — run the producers in
   `code/build/RawDataScripts/*/` (each has a `SOURCE_NOTES.md`). The shipped `data/raw/`
   already contains these producers' outputs, so this is only needed to rebuild from
   primary sources.
2. **Build the master datasets** — `code/build/UIMacro_BuildData.do` → `data/processed/`.
3. **Export the factor-model inputs** — `code/exporters/OutputDataSetsUIMacro_*.do`.
4. **Estimate the factor model + bootstrap** — `code/matlab/Factor_FrontEnd_*.m`,
   writing CSVs to `output/factor_results/`.
5. **Final analysis** — `code/analysis/*.do`.
6. **Structural model** — `code/model/RunModel.m`.
7. **Assemble exhibits** — `code/tex/make_tables.py` writes the table `.tex` into
   `output/tables/`; compile `code/tex/MacroElasticity_JPE_Rev3_1_I.tex` (it `\input`s
   `output/tables/` and includes `output/figures/`).

Re-running the build on the shipped raw reproduces the analysis datasets exactly on every
consumed double-precision variable. The only non-identical items are (i) two
`float`-stored families (`unemp_rate_laus` and the `tight2` vacancy chain), which differ
at the last float bit from Stata/MP's non-deterministic parallel-summation order
(display-identical; a `set processors 1` build matches to the last bit), and (ii) the
`bordersegment` cluster id, which is a pure relabeling (identical partition, so
clustered/bootstrap inference is unaffected). Inference clusters on `bordersegment`
(state-pair group) throughout; reported p-values are one-sided (directional).

### Synthetic stand-in for the proprietary HWOL vacancy data

The HWOL county/state vacancy series is proprietary and is **not** in this archive —
**nothing in this package is confidential; only the synthetic stand-in is provided.** In
its place, `synthetic-data/` ships a **public-data synthetic** vacancy panel
(`new_vac_synthetic.dta` and `StateMonthlyBorderData_synthetic.dta`), generated by
`code/build/Make_Synthetic_Vacancies.do` (seed 80539) from a Beveridge model on public
JOLTS openings and LAUS unemployment (validated against the real data: log-vacancy
correlation ≈0.87). It is **not** fit to HWOL — manufacturing the published
benefit→vacancy estimates from public inputs would bake in the answer.

- The pipeline reads the vacancy files exclusively through the `${vacfile}`/`${statefile}`
  globals in `code/config.do`, which **default to the synthetic files**. Everything
  vacancy-gated therefore *runs* and produces sensible, sign-consistent output — but the
  vacancy-dependent exhibits are **demonstrative and will NOT reproduce the published
  point estimates** (see the exhibit table below). Every non-vacancy exhibit is exact.
- A replicator with licensed HWOL access reproduces the **published** vacancy numbers by
  pointing `${vacfile}` at the licensed county file and `${statefile}` at the licensed
  state file (schemas in the codebook above) and re-running from step 2.

Full mechanics: `code/build/SYNTHETIC_VACANCY_PATH.md`.

---

## List of tables and programs

The last column states whether the exhibit reproduces **without** the confidential HWOL
data (i.e., as shipped, on the synthetic stand-in). "Yes" = reproduces the published
numbers exactly (bootstrap-based p-values/SEs exactly on the same software versions; see
the MATLAB caveat under Controlled Randomness). "NO" = requires licensed HWOL for the
published numbers; the shipped run produces demonstrative synthetic-data output.

| Exhibit | Label in tex | Producing program(s) (→ `make_tables.py` where applicable) | Output | Reproducible without HWOL? |
|---|---|---|---|---|
| Table 1 | `tab:Benefits_on_unemp` | exporters + `Factor_FrontEnd_{Bench,EmpShare,Industry,Dist30,CBSA,Controls,Scrambles,Uhlig}.m` | `output/tables/Benefits_on_unemp.tex` | Yes |
| Table 2 | `tab:Forward_Spec` | `Factor_FrontEnd_QDK.m` + `ProcessQDK.m` | `output/tables/Forward_Spec.tex` | Yes |
| Table 3 | `tab:Benefits_on_JobCreation` | `Factor_FrontEnd_HWOL.m` (cols 1–2), `Factor_FrontEnd_EmpQCEW.m` (col 3) | `output/tables/Benefits_on_JobCreation.tex` | **Cols 1–2 (Vacancies, Tightness): NO.** Col 3 (Employment): Yes |
| Table 4 | `tab:Benefits_on_Wages` | `Factor_FrontEnd_QWIW.m` | `output/tables/Benefits_on_Wages.tex` | Yes |
| Figure 1(a,b) | `fig:binscatter_du`, `fig:binscatter_qdu` | `analysis/Binscatter_Figures.do` | `output/figures/DiffWks.pdf`, `QDWks.pdf` | Yes |
| Table A-1 | `tab:MO_V_U` | `analysis/MO_Tightness_Figures.do` | `output/tables/MO_V_U.tex` | **Vacancy & Tightness cols: NO.** Unemployment col: Yes |
| Table A-2 | `tab:Monte-Carlo-Results` | `matlab/RunMonteCarlo.m` | `output/tables/Monte_Carlo_Results.tex` | Yes |
| Table A-3 | `tab:Benefits_on_unemp_OLS` | `analysis/Table1_OLS.do`, `Table1_OLS_Controls.do` + `exporters/OutputDataSetsUIMacro_Scrambles.do` (scrambled cols 3–4) | `output/tables/Benefits_on_unemp_OLS.tex` | Yes |
| Table A-4 | `tab:Endog_Vars` | `analysis/Endog_Vars.do` | `output/tables/Endog_Vars.tex` (comparison file; published table typeset in the tex) | Yes |
| Table A-5 | `calib` | `model/RunModel.m` + `analysis/ModelPanelRegression.do` (+ `Factor_FrontEnd_Bench.m` for the Data target) | `output/tables/Model_Calibration.tex` | Yes |
| Table A-6 | `valid` | `model/RunModel.m` + `Factor_FrontEnd_{Bench,HWOL}.m` | `output/tables/Model_Validation.tex` | **Data-row Vacancy/Tightness cells: NO.** Rest: Yes |
| Table A-7 | `tab:Mobility_LODES` | `analysis/Mobility_LODES.do` | `output/tables/Mobility_LODES.tex` | Yes |
| Table A-8 | `tab:Imputed_Results` | imputation chain (`Impute_Input.do` → `Run_Impute_Border.m` → `Impute_to_Stata.do`) + `Imputed_Results.do` | `output/tables/Imputed_Results.tex` (comparison file; published table typeset in the tex) | **NO** (all columns run on `${vacfile}`) |
| Table A-9 | `app_tab:A-1` | `analysis/TableA2.do` | `output/tables/LAUS_Imputation.tex` | Yes |
| Table A-10 | `tab:Effect_of_Distance` | `Factor_FrontEnd_Distance.m` | `output/tables/Effect_of_Distance.tex` | Yes |
| Table A-11 | `tab:Benefits_on_unemp_beg` | `Factor_FrontEnd_{Bench,EmpShare,Industry,Dist30,CBSA,Controls,Scrambles}Beg.m` | `output/tables/Benefits_on_unemp_beg.tex` | Yes |
| Table A-12 | `tab:macroeffects_beg` | `Factor_FrontEnd_HWOL_Beg.m` (cols 1–2), `Factor_FrontEnd_EmpQCEW_Beg.m` (col 3) | `output/tables/macroeffects_beg.tex` | **Cols 1–2 (Vacancies, Tightness): NO.** Col 3: Yes |
| Table A-13 | `tab:Benefits_on_unemp_SNAP_Mortgage` | `Factor_FrontEnd_ControlsOnebyOne.m` (+ `Factor_FrontEnd_Bench.m` for the baseline column) | `output/tables/Benefits_on_unemp_SNAP_Mortgage.tex` | Yes |
| Table A-14 | `tab:Benefits_on_unemp_stimulus_taxes` | `Factor_FrontEnd_Controls{,Lev}OnebyOne.m` (+ `Factor_FrontEnd_Bench.m` for the baseline column) | `output/tables/Benefits_on_unemp_stimulus_taxes.tex` | Yes |
| Table A-15 | `tab:Benefits_on_unemp_other_policies` | `Factor_FrontEnd_ControlsOnebyOne.m` (+ `Factor_FrontEnd_Bench.m` for the baseline column) | `output/tables/Benefits_on_unemp_other_policies.tex` | Yes |
| Table A-16 | `tab:app_Benefits_on_Wages` | `Factor_FrontEnd_QWIW{,Stayers}.m` | `output/tables/app_Benefits_on_Wages.tex` | Yes |
| Figure A-1 | `fig:MO_vacPuD` | `analysis/MO_Tightness_Figures.do` | `output/figures/motight_pooled.pdf`, `motight_all.pdf` | **NO** (state HWOL vacancies) |
| Figure A-2 | `fig:Tightness_MO_Borders` | `analysis/MO_Tightness_Figures.do` | `output/figures/motight_border*.pdf` | **NO** (state HWOL vacancies) |
| Figure A-3 | `fig:initial-guess` | `matlab/Fig_InitialGuess.m` | `output/figures/initial_guess.pdf` | Yes |
| Figure A-4 | `fig:endogeneity_test_unemp` | `model/RunModel.m` + `model/Fig_StateU.m` | `output/figures/StateUCrop.pdf` | Yes |
| Figure A-5 | `fig:Counties_Map` | `analysis/Make_CountyMap.py` | `output/figures/countymap2.png` | Yes |
| Figure A-6 | `fig:Benefit_Maps` (+ `_42`…`_96`) | `analysis/Make_BenefitMaps.py` | `output/figures/AllMaps{42,48,…,96}.jpg` (ten files, every 6) | Yes |
| In-text §4.2 quasi-difference decomposition | — | `analysis/Check_UFU.do` | `output/tables/Check_UFU.tex` (comparison file; numbers typeset in the tex) | Yes |
| In-text policy-scenario numbers | — | `analysis/Derived_Policy_Calcs.do` | `output/factor_results/Derived_Policy_Calcs.csv` | Yes (the tightness scenario row re-uses the published HWOL-based coefficient 0.101 as a stated constant) |
| In-text endogeneity-appendix numbers | — | `analysis/Endog_Bartik.do`, `Endog_Bartik_Scrambles.do`, `Bias_Sim_Shares.do` | `output/factor_results/*.csv` | Yes |

Notes on the three "comparison file" rows: the published versions of Table A-4, Table A-8,
and the §4.2 in-text coefficients are typeset directly in the paper source; the pipeline
still generates the corresponding `.tex`/`.csv` from the shipped data so the replicator
can compare. For Table A-8 this is because the published numbers require licensed HWOL;
for Table A-4, the script header documents that the published specification was originally
hand-assembled, and the generated version reproduces it up to the preserved specification.

---

## References

**Data:**

- Beacon Hill Institute. 2012. *State Competitiveness Report* (overall state scores,
  2005–2012 editions). Dataset. https://beaconhill.org/economic-competitiveness/
  (accessed circa 2013).
- Dube, Arindrajit, T. William Lester, and Michael Reich. 2010. Contiguous border
  county-pair data accompanying "Minimum Wage Effects Across State Borders." Dataset,
  *Review of Economics and Statistics* 92(4): 945–964.
  https://doi.org/10.1162/REST_a_00039 (accessed circa 2013–2014).
- Federal Housing Finance Agency. 2018. *House Price Index: Annual County Developmental
  Index, All-Transactions* (HPI_AT_BDL_county). Dataset, 2018 vintage.
  https://www.fhfa.gov/data/hpi (accessed July 26, 2018).
- Federal Reserve Bank of New York. 2018. *Consumer Credit Panel/Equifax: County-Level
  Household Debt-to-Income*. Public-use dataset.
  https://www.newyorkfed.org/microeconomics/databank.html (accessed circa 2018).
- Hagedorn, Marcus, Iourii Manovskii, and Kurt Mitman. 2025. "Data and Code for: The
  Impact of Unemployment Benefit Extensions on Employment: The 2014 Employment Miracle?"
  American Economic Association [publisher]; ICPSR [distributor].
  https://doi.org/10.3886/E205681V1 (the authors' own deposit; the daily benefit-weeks
  file redistributed here is byte-identical to the deposit's).
- Kaplan, Greg, Kurt Mitman, and Giovanni L. Violante. 2020. Replication archive for
  "Non-durable Consumption and Housing Net Worth in the Great Recession." Dataset,
  *Journal of Public Economics* 189: 104176.
  https://doi.org/10.1016/j.jpubeco.2020.104176 (access date not recorded; the archive
  file ships here).
- Missouri Census Data Center. 2012 (edition approximate). *Geocorr: Geographic
  Correspondence Engine* (ZCTA-to-county crosswalk). Dataset.
  https://mcdc.missouri.edu/applications/geocorr.html (accessed circa 2013).
- Recovery Accountability and Transparency Board. 2012. *Cumulative National Summary of
  ARRA Awards, February 17, 2009 – December 31, 2012*. Dataset (Recovery.gov, since
  decommissioned; archival copies at https://web.archive.org/web/*/recovery.gov)
  (accessed circa 2013).
- Saiz, Albert. 2010. Replication data for "The Geographic Determinants of Housing
  Supply." Dataset, *Quarterly Journal of Economics* 125(3): 1253–1296.
  https://doi.org/10.1162/qjec.2010.125.3.1253 (access date not recorded; the
  time-invariant archive file ships here).
- Shimer, Robert. 2012. Published job-separation series accompanying "Reassessing the
  Ins and Outs of Unemployment." Dataset, *Review of Economic Dynamics* 15(2): 127–148.
  https://doi.org/10.1016/j.red.2012.02.001 (accessed circa 2013–2014).
- Small Business & Entrepreneurship Council. 2012. *Small Business Survival Index / Small
  Business Policy Index* (2005–2012 editions). Dataset. https://sbecouncil.org/
  (accessed circa 2013).
- Tax Foundation. 2013. *State Business Tax Climate Index* (2005–2013 editions). Dataset.
  https://taxfoundation.org/research/all/state/state-business-tax-climate-index/
  (accessed circa 2013).
- The Conference Board. 2017. *Help Wanted OnLine (HWOL) Data Series* (county and state
  vacancy extracts). Proprietary dataset. https://www.conference-board.org/ (county
  extract accessed April 2017; state series accessed July 25, 2018; not redistributable).
- U.S. Bureau of Economic Analysis. 2013. *Regional Economic Accounts, Table CA25N:
  Total Full-Time and Part-Time Employment by NAICS Industry* (November 2013 local-area
  release). Dataset.
  https://www.bea.gov/data/employment/employment-county-metro-and-other-areas
  (accessed circa November 2013).
- U.S. Bureau of Economic Analysis. 2016. *Prototype Quarterly Gross Domestic Product by
  State*, 2005Q1–2016Q1. Dataset. https://www.bea.gov/data/gdp/gdp-state (accessed
  July 2016).
- U.S. Bureau of Labor Statistics. 2013. *Job Openings and Labor Turnover Survey
  (JOLTS)*. Dataset. https://www.bls.gov/jlt/ (accessed circa 2013).
- U.S. Bureau of Labor Statistics. 2014. *Local Area Unemployment Statistics (LAUS)*
  (including the LAUS additivity ratios). Dataset; archived extracts of four vintages.
  https://www.bls.gov/lau/ (accessed June 22, 2013; September 2014; January 2015;
  December 2015).
- U.S. Bureau of Labor Statistics. 2015. *Quarterly Census of Employment and Wages
  (QCEW)*, 1975–2015. Dataset. https://www.bls.gov/cew/ (accessed circa 2015–2016).
- U.S. Census Bureau. 2011. *Population Estimates Program: Annual County Resident
  Population Estimates* (archived pre-rebase Vintage-2011 series, 2000–2011). Dataset.
  https://www.census.gov/programs-surveys/popest.html (accessed circa 2012).
- U.S. Census Bureau. 2013. *Quarterly Summary of State and Local Government Tax
  Revenue*, Table 3. Dataset. https://www.census.gov/programs-surveys/qtax.html
  (accessed circa 2013).
- U.S. Census Bureau. 2014. *Longitudinal Employer-Household Dynamics: Quarterly
  Workforce Indicators (QWI)*, 2014Q3 release. Dataset.
  https://lehd.ces.census.gov/data/ (accessed September 18, 2018).
- U.S. Census Bureau. 2015. *LEHD Origin-Destination Employment Statistics (LODES)*,
  2002–2015. Dataset. https://lehd.ces.census.gov/data/lodes/ (accessed circa
  2017–2018).
- U.S. Census Bureau. 2025. *Census Geography Files: Gazetteer County Centroids, CBSA
  Delineation Crosswalks, and County Cartographic Boundary Shapefile*
  (cb_2025_us_county_20m). Datasets. https://www.census.gov/geographies/ (shapefile
  accessed 2025–2026; crosswalk vintages not recorded).
- U.S. Department of Agriculture, Economic Research Service. 2018. *SNAP Policy
  Database*. Dataset. https://www.ers.usda.gov/data-products/snap-policy-data-sets
  (accessed 2018).
- U.S. Department of Labor, Employment and Training Administration. 2013. *Extended
  Benefits and Emergency Unemployment Compensation Trigger Notices*. Dataset.
  https://oui.doleta.gov/unemploy/trigger/ (compiled by the authors through
  December 2012).
- U.S. Department of Labor, Employment and Training Administration. 2014 (vintage
  approximate). *Unemployment Insurance Financial Data Handbook (ET Handbook 394)*.
  Dataset. https://oui.doleta.gov/unemploy/hb394.asp (access date not recorded).
- U.S. Department of Labor, Employment and Training Administration, and State Workforce
  Agencies. 2014 (vintage approximate). *County Unemployment-Insurance Continuing-Claims
  Records* (administrative compilation by the authors). https://www.dol.gov/agencies/eta.

**Related published sources for the data construction:**

- Gyourko, Joseph, Albert Saiz, and Anita Summers. 2008. "A New Measure of the Local
  Regulatory Environment for Housing Markets: The Wharton Residential Land Use Regulatory
  Index." *Urban Studies* 45(3): 693–729.
- Şahin, Ayşegül, Joseph Song, Giorgio Topa, and Giovanni L. Violante. 2014. "Mismatch
  Unemployment." *American Economic Review* 104(11): 3529–3564. (Replication archive:
  https://doi.org/10.3886/E112705V1 — the HWOL access route used here.)
