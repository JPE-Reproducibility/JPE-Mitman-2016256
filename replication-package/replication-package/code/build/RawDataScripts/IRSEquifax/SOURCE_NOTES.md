# IRSEquifax county income panel

`IRSEquifax.dta` (`fipsnumeric year quarter agi`, county × quarter 2004Q1–2012Q4,
N=113,256) is merged by the main build (`MakeDataSetsMainPaper_v5_newvac.do`,
`merge m:1 fipsnumeric year quarter`).

## What the paper uses (and the trim)
Only **`agi`** is consumed downstream: it is annual **IRS SOI** county adjusted gross
income (constant within a county-year, expanded across the four quarters), and feeds
**`diff_agi`** — the cross-county pair difference of `log(agi)` built in
`MakeDataControls.do` — which is a control in all three `tab:Endog_Vars` regressions
(`code/analysis/Endog_Vars.do`: `regife` / `reghdfe` / `ivreg2`).

This producer keeps only `agi`, the single column consumed downstream. (The
net-worth/income source panel carries additional columns — `housing_assets*`,
`mortgage_*`, `nreturns`, `wage_income`, `dividends`, `interest`, `nonwage_income`,
`other_nonwage_income` — but no paper artifact uses them, so they are not carried into
`MakeDataControls`.) (The debt-to-income control `diff_dti_high` in the same table comes
from `county_debt.dta`, not here.)

## Source (provided, citable intermediate)
`networth_all_counties_2004q1_2012q4.dta` — the county-quarter net-worth/income panel
from the **published replication archive** for:

> Greg Kaplan, Kurt Mitman & Gianluca Violante, "Non-Durable Consumption and Housing
> Net Worth in the Great Recession: Evidence from Easily Accessible Data," *Journal of
> Public Economics*.

In that archive the file lives in `RawData/`. Its construction (IRS SOI county income +
IRS/Equifax credit + Flow of Funds + ACS + Zillow) is documented in that project's
`data_generation.tex` and `prog/`. The underlying raw inputs ran on the original RA's
machine and are not redistributed; we therefore **cite the published archive** and ship
the built county panel as the input: `networth_all_counties_2004q1_2012q4.dta`
(~82 MB), shipped in `data/raw/`.

## Producer
**`Make_IRSEquifax.do`** subsets that net-worth panel and renames `countycode→fipsnumeric`
(the `CountyIncome` subsetting step), keeping only `agi`.

