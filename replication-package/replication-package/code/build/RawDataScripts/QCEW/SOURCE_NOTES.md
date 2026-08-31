# QCEW chain → `QCEWAllYears_2014Q4.dta` (build input)

BLS Quarterly Census of Employment and Wages, county × month employment and weekly
wages (total + private). Feeds the build's `qcew_emp`, `qcew_emp_tot`, `qcew_wage`,
`qcew_wage_tot`, and `qcew_ui_tax_rate`. Six layers (run in order):

1. **`1_construct_qcew_2015.do`** — raw → `qcew.dta` (quarterly, 1990–2015).
   Reads the BLS QCEW county "high-level" Excel files
   (`allhlcn{yy}{q}.xls`/`.xlsx`, sheet `US_St_Cn_MSA`) from
   `data/raw/QCEW/{yyyy}_all_county_high_level/`, keeps
   counties + total (sectorcode 0) and private (sectorcode 5), and appends to
   `qcew.dta` with `qcew_all_*`/`qcew_priv_*` (monthly employment `empm1/2/3`,
   weekly wage, establishments). Set `pause on`→off to run in batch. The
   `drop V-Z` on the 2010+ layout is `capture`-wrapped (the "variable V not found"
   messages are harmless).
1b. **`1b_QCEW_Historical_1975_1989.do`** — raw annual county CSVs
   `data/raw/QCEW/{1975..1989}.q1-q4 10 Total, all industries.csv` (each carries all
   ownership codes; `own_code` 0 = total, 5 = private) → `QCEW_Historical_County_total.dta`
   + `QCEW_Historical_County_private.dta` (the pre-1990 history; the allhlcn Excel only
   begin in 1990).
1c. **`1c_QCEW_County_2014.do`** — raw `data/raw/QCEW/2014.q1-q3 10 Total, all industries.csv`
   → `QCEW_County_2014_total.dta` + `QCEW_County_2014_private.dta` (the 2014 refresh).
2. **`2_MergeFullQCEW.do`** — `qcew.dta` → monthly `QCEWAllYears`. Reshapes the
   `empm1/2/3` quarterly columns long into months and appends the historical
   1975–1989 monthly data (`QCEW_Historical_County_total/private`, from layer 1b).
3. **`3_MergeFullQCEW_2014_Q4.do`** — `QCEWAllYears` + the 2014 county refresh
   (`QCEW_County_2014_total/private`, from layer 1c) → `QCEWAllYears_2014Q4` (monthly, 1975–2014).
4. **`4_MakeQCEWTaxRate.do`** — + state UI tax receipts
   (`UI_Tax_Data_Fips`, built by `BuildUITax.do` from the shipped DOL receipts data) →
   `qcew_ui_tax_rate = 1000·receipts/Σ qcew_wage` (state × fiscal-year) → the build
   input. (Same recipe as the QWI tax step.)


## Locations in this archive
- Raw: the allhlcn high-level Excel in `data/raw/QCEW/{yyyy}_all_county_high_level/`,
  and the annual county CSVs `data/raw/QCEW/{1975..1989}.q1-q4 ...csv` (history) +
  `data/raw/QCEW/2014.q1-q3 ...csv` (refresh).
- All chain outputs are built (nothing shipped pre-built): per-year intermediates and the
  historical/2014 county files go to `data/raw/QCEW/Output/` and `data/raw/`; the final
  `QCEWAllYears_2014Q4.dta` lands in `data/raw/`.
