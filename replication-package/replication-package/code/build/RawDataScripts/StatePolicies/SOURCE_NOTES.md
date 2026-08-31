# StatePolicies state-policy controls (sbsi / sbtc / bhi / judicial)

`StatePolicies.dta` is a combined state × year × quarter file the build merges. Four of its
columns are state-policy controls used by the **Controls** IFE experiment
(`code/exporters/OutputDataSetsUIMacro_Controls.do`) and `code/analysis/Table1_OLS_Controls.do`:

| var | index | source raw (in this folder) | coverage |
|---|---|---|---|
| `sbsi` | SBE Council Small Business Survival/Policy Index | `SBSI_Data.csv` | annual 2005-2012 |
| `bhi` | Beacon Hill Institute State Competitiveness (score) | `BHI_Data_2005-2012-Scoreonly.csv` | annual 2005-2012 |
| `sbtc` | Tax Foundation State Business Tax Climate Index | `SBTC_Data_Scoreonly.csv` | quarterly 2005Q3-2012Q4 |
| `judicial` | judicial-foreclosure-state flag (0/1) | `Judicial.csv` | time-invariant |

## Producer
**`Make_StatePolicies_Indices.do`** builds all four from the raw
above (abbreviation→FIPS crosswalk inline) → `StatePolicies_indices.dta`
(`fipsstate year quarter sbsi sbtc bhi judicial`, 2005-2012). Key encoding details:
- **SBTC** raw has no header: 32 columns = quarters descending from 2013Q2 to 2005Q3. Each
  annual SBTC index spans `Y-1 Q3 … Y Q2` (the index updates at Q3), so within an index-year the
  four quarter values repeat. (The `..._Scoreonly 2.ods` is the headered version of the same data.)
- **AK (2) / HI (15)** dropped (no Alaska/Hawaii border pairs).
- **DC (11)** blanked for all four indices: the shipped StatePolicies excludes DC entirely (DC is
  not classified for these state-policy indices), but the on-hand `SBSI_Data.csv`/`Judicial.csv`
  include DC — so it is nulled to match (DC pairs *are* in the sample, so this keeps the
  Controls-experiment sample identical).

## Tax columns (`property` / `general_sales` / `income` / `corp_income` / `total`)
Built by **`Make_StatePolicies_Taxes.do`** → `StatePolicies_taxes.dta`
(`fipsstate year quarter` + the five columns, quarterly 1994Q1-2012Q4).

| var | source raw (Census tax-type code) |
|---|---|
| `property` | T01 Property Taxes |
| `general_sales` | T09 General Sales and Gross Receipts Taxes |
| `income` | T40 Individual Income Taxes |
| `corp_income` | T41 Corporation Net Income Taxes |
| `total` | Total Taxes |

Source = **`IouriiStateTax.dta`** (shipped in `data/raw/`, a provided Census
intermediate — too large for git): the U.S. Census Bureau *Quarterly Summary of State & Local
Tax Revenue* in long form. We use `cat_desc == "Table 3 - … by State and Type of Tax"`
(state×type quarterly collections, $ thousands, not seasonally adjusted), with `geo_code` = state
postal abbreviation and `per_name` = `Q<q><yyyy>`. The companion `IouriiStateFinances.dta` is the
*annual* finances file and lacks property tax, so it is not used. Same edge handling as the
indices: AK/HI dropped, **DC tax nulled** (the shipped panel excludes DC from these controls), and `year<=2012`
trims the lone 2013Q1 quarter beyond the shipped panel.


## NOT built here
`StatePolicies` also carries SNAP columns (`bbce`, `bbce_asset`) — built via the SNAP
policy-database producer (separate folder).
