#!/usr/bin/env python3
"""
Recompute the four in-text numbers that do not reproduce.

Run from the package root (the directory holding code/, data/, output/):
    python3 verify/recompute_intext.py

Inputs, all shipped in the archive:
    data/processed/UIMacro_DataControls.dta   -> 1,132 ; 1,113 ; 59
    data/processed/UIMacro_RevisionData.dta   -> 1.121 / 0.415  (both counties per pair)
    data/raw/claims_quarterly.dta             -> 1.121 / 0.415
    data/raw/population_age.dta               -> 1.121 / 0.415
"""
import numpy as np
import pandas as pd

DC  = "data/processed/UIMacro_DataControls.dta"
RD  = "data/processed/UIMacro_RevisionData.dta"
CQ  = "data/raw/claims_quarterly.dta"
POP = "data/raw/population_age.dta"

rows = []
def report(label, published, got, note=""):
    rows.append((label, published, got, note))


# ---------------------------------------------------------------- 1,132
# Paper: "Among 1,172 border county pairs used in our analysis, 1,132 have
# different benefits for at least one quarter."
# DataControls is already collapsed to county_index==1, and carries the
# within-pair log benefit gap directly as diff_logmeanwks.  A pair "has
# different benefits" in a quarter when that gap is non-zero.
d = pd.read_stata(DC, columns=["pair_id_numeric", "year", "diff_logmeanwks"])
w = d[(d.year >= 2008) & (d.year <= 2012)].copy()
w["differs"] = w.diff_logmeanwks.abs() > 1e-9
per_pair = w.groupby("pair_id_numeric")["differs"].sum()

report("1,172 pairs total", "1,172", f"{per_pair.size:,}")
report("1,132 pairs differing >=1 quarter", "1,132", f"{(per_pair > 0).sum():,}",
       f"{(per_pair == 0).sum()} pairs never differ (paper implies 40)")
report("14 median differing quarters", "14", f"{per_pair.median():.0f}")
report("0 to 18 range", "0 to 18", f"{per_pair.min():.0f} to {per_pair.max():.0f}")

# Why it misses: the extra pairs differ in only a handful of quarters.
small = per_pair[(per_pair > 0) & (per_pair <= 3)]
print(f"[1,132] pairs differing in 1-3 quarters only: {small.size}"
      f"  (gap to paper is {(per_pair > 0).sum() - 1132})")

# Robustness: the count does not move with the zero-tolerance.
tols = [1e-9, 1e-6, 1e-4, 1e-3, 5e-3, 1e-2, 2e-2]
counts = [(w.assign(x=w.diff_logmeanwks.abs() > t)
            .groupby("pair_id_numeric")["x"].sum() > 0).sum() for t in tols]
print(f"[1,132] count vs tolerance {list(zip(tols, counts))}")


# ---------------------------------------------------- 1,113 and 59
# Paper: border counties below 15% of state employment number 1,113 (avg 2%);
# those at or above 15% number 59 (avg 35%).
# emp_share is built in MakeDataSetsMainPaper_v5_newvac.do L164-L166 as
# emp_laus/emp_state_u in 2012q4, then carried as a pair-constant.
# This mirrors analysis/Bias_Sim_Shares.do L26-L37.
e = pd.read_stata(DC, columns=["pair_id_numeric", "emp_share"])
share = e.groupby("pair_id_numeric")["emp_share"].mean().dropna()

n_small, n_large = (share < 0.15).sum(), (share >= 0.15).sum()
report("1,113 counties below 15%", "1,113", f"{n_small:,}")
report("59 counties at/above 15%", "59", f"{n_large:,}")
report("2% avg share, small group", "2", f"{100 * share[share < 0.15].mean():.1f}")
report("35% avg share, large group", "35", f"{100 * share[share >= 0.15].mean():.1f}")

# Why it misses: the archived vintage puts 5 MORE pairs at or above the 0.15
# cutoff than the published text did.  Recovering 1,113/59 requires the five
# lowest pairs currently above the line to fall below it.
above = sorted(share[share >= 0.15].values)
below = sorted(share[share < 0.15].values)
print(f"[1,113/59] 5 lowest above the cutoff: {[round(v, 4) for v in above[:5]]}")
print(f"[1,113/59] 5 highest below the cutoff: {[round(v, 4) for v in below[-5:]]}")
print(f"[1,113/59] moving those 5 below 0.15 gives "
      f"{len(below) + 5:,} / {len(above) - 5}  <- the published split")
print("[1,113/59] note: two are within 0.001 of the cutoff, but three sit "
      "~0.011 above it, so this is not a pure rounding knife-edge")


# ------------------------------------------------- 1.121 and 0.415
# Paper (Alternative Endogeneity Test): regress a county's continuing
# claims/population on the adjacent out-of-state county's and on the state
# aggregate, in 2007.  Published state 1.121, adjacent 0.415.
#
# NOTE: this one CANNOT come from UIMacro_DataControls.dta.  That file keeps
# only county_index==1, and the regression needs both counties of each pair.
# Use UIMacro_RevisionData.dta.  Mirrors analysis/TableA2.do L113-L160.
base = pd.read_stata(RD, columns=["pair_id_numeric", "fipsnumeric", "year",
                                  "quarter", "county_index", "fipsstate",
                                  "unemp_rate_laus"])
cl  = pd.read_stata(CQ)
pop = pd.read_stata(POP)

cl = cl.merge(pop, on=["fipsnumeric", "year"], how="inner")
cl["fipsstate"] = np.floor(cl.fipsnumeric / 1000)
cl["claimspop"] = cl.cont_claims / cl.popestimate

# State aggregate: sum claims over ALL counties / sum population.
state_pop = (cl.drop_duplicates(["fipsnumeric", "year"])
               .groupby(["fipsstate", "year"], as_index=False)["popestimate"]
               .sum().rename(columns={"popestimate": "state_pop"}))
state = (cl.groupby(["fipsstate", "year", "quarter"], as_index=False)["cont_claims"]
           .sum().rename(columns={"cont_claims": "state_cc"})
           .merge(state_pop, on=["fipsstate", "year"], how="inner"))
state["state_claimspop"] = state.state_cc / state.state_pop

df = (base.merge(cl[["fipsnumeric", "year", "quarter", "claimspop"]],
                 on=["fipsnumeric", "year", "quarter"], how="left")
          .merge(state[["fipsstate", "year", "quarter", "state_claimspop"]],
                 on=["fipsstate", "year", "quarter"], how="left"))

# "Other county" = the adjacent out-of-state county in the same pair-quarter.
# NB: use a POSITIONAL first/last, matching Stata's claimspop[1] / claimspop[2].
# pandas' transform("first"/"last") skips NaN, which would silently fill a
# missing county from its neighbour and keep 16 rows Stata correctly drops.
df = df.sort_values(["pair_id_numeric", "year", "quarter", "county_index"])
wide = df.pivot_table(index=["pair_id_numeric", "year", "quarter"],
                      columns="county_index", values="claimspop",
                      dropna=False, aggfunc="first")
wide.columns = ["cp1", "cp2"]
df = df.merge(wide.reset_index(), on=["pair_id_numeric", "year", "quarter"], how="left")
df["othercp"] = np.where(df.county_index == 1, df.cp2, df.cp1)

r = df[(df.year == 2007)][["claimspop", "othercp", "state_claimspop"]].dropna()
X = np.column_stack([np.ones(len(r)), r.othercp, r.state_claimspop])
b = np.linalg.lstsq(X, r.claimspop.values, rcond=None)[0]

report("1.121 state coefficient", "1.121", f"{b[2]:.3f}", f"N={len(r):,}")
report("0.415 adjacent coefficient", "0.415", f"{b[1]:.3f}",
       "original producing script was lost; this is the authors' reconstruction")


# ---------------------------------------------------------------- output
wdt = [max(len(str(r[i])) for r in rows + [("quantity", "paper", "recomputed", "note")])
       for i in range(4)]
hdr = ("quantity", "paper", "recomputed", "note")
line = "  ".join("-" * w for w in wdt)
print("\n" + "  ".join(h.ljust(w) for h, w in zip(hdr, wdt)))
print(line)
for r in rows:
    flag = "" if r[1].replace(",", "") == r[2].replace(",", "") else "  <-- MISS"
    print("  ".join(str(c).ljust(w) for c, w in zip(r, wdt)) + flag)
