# %%

import pandas as pd
import seaborn as sns
from pathlib import Path

# %%

perf_win = [
    328.876,
    289.269,
    289.233,
    316.402,
    290.582,
    288.296,
    327.861,
    291.917,
    315.532,
    298.469,
    299.408,
    292.894,
    280.015,
    332.367,
    289.039,
    296.348,
    307.98,
    285.67,
    293.989,
    302.821,
]

perf_grp = [
    362.063,
    336.604,
    380.151,
    344.964,
    325.822,
    362.045,
    337.916,
    368.373,
    380.644,
    341.625,
    527.42,
    386.924,
    373.228,
    367.943,
    310.138,
    309.074,
    317.532,
    317.993,
    307.666,
    312.15,
]

perf_mat = [
    269.978,
    269.113,
    266.89,
    271.304,
    353.503,
    423.918,
    273.904,
    262.333,
    259.989,
    271.199,
    271.568,
    265.615,
    265.85,
    272.742,
    274.626,
    264.574,
    270.547,
    289.51,
    290.036,
    265.611,
]

# %%
vals = {"win": perf_win, "grp": perf_grp, "mat": perf_mat}
df = pd.DataFrame(vals)

bp = sns.boxplot(df)

bp.figure.savefig("demo.png", dpi=300)

# %%
names = ["../queries/agg_windows.sql", "../queries/agg_group_by.sql", "../queries/agg_group_by_mat.sql"]

name = f"{'-'.join(Path(k).stem for k in names)}.png"
# [Path(f).stem for f in names]

# %%
df = pd.read_csv("output/cte_materialized-cte_not_materialized.csv", index_col=0)
sns.histplot(df)

# %%
meanprops = {"marker": "o", "markerfacecolor": "white", "markeredgecolor": "black", "markersize": "10"}
the_boxplot = sns.boxplot(df, showmeans=True, meanprops=meanprops)
# %%

#
from scipy.stats import norm
import numpy as np
# %%


df["lognormal"] = np.log(df[df.columns[0]])
df
# %%
# sns.boxplot(df["lognormal"])
sns.histplot(df["lognormal"])
df    # %%

# %%
