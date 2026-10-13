# Subdiffusive Random Growth of Bacterial Size — Research Archive

> **Important scientific note (October 2026).** This repository archives an unpublished manuscript and its supporting materials. Following peer review, we concluded that the experimental data presented in the manuscript do **not** establish intrinsic subdiffusive bacterial growth. Frame-to-frame errors in cell-size measurements can produce both an approximately lag-independent contribution to the variance of size increments and an anticorrelation between consecutive increments. We did not rule out this alternative explanation. Therefore, the reported experimental exponent near 0.25 and its proposed biological interpretation should **not** be regarded as established findings.

## Why we are sharing this work

Although we are not pursuing further journal submission of this manuscript, we believe some of its theoretical and methodological components may be useful independently of the unresolved experimental interpretation. We are making the manuscript, supplementary material, and simulation/figure-generation code available for inspection, reproduction, and further research.

In particular, the archive contains:

- **A viscoelastic stochastic-growth model.** A collection of elements with heterogeneous relaxation times can transform microscopic white-noise forcing into temporally correlated macroscopic fluctuations. Under the model's stated assumptions, a power-law relaxation-time distribution leads to subdiffusive scaling with exponent $\alpha=3-2\beta$ for $1<\beta<3/2$ in the appropriate asymptotic regime. This is a theoretical mechanism, **not evidence** that it is the mechanism operating in the experimental system.
- **Analyses of statistical biases in cell-growth measurements.** The manuscript and supplement study how conditioning growth-rate estimates on relative cell-cycle age, cell size, or elapsed time can produce apparent acceleration or deceleration, including first-passage and survival-selection effects.
- **Numerical and plotting code.** Scripts accompanying the study are provided to help reproduce the model calculations and figures.

## Interpretation and limitations

Let $x_{\mathrm{obs}}(t)=x_{\mathrm{true}}(t)+\varepsilon(t)$, where $\varepsilon(t)$ is frame-to-frame independent measurement error of variance $\sigma_\varepsilon^2$, also independent of the true process. Then, for nonzero time lag $\Delta t$,

$$
\operatorname{Var}[x_{\mathrm{obs}}(t+\Delta t)-x_{\mathrm{obs}}(t)]
=\operatorname{Var}[x_{\mathrm{true}}(t+\Delta t)-x_{\mathrm{true}}(t)] + 2\sigma_\varepsilon^2.
$$

For consecutive non-overlapping single-frame increments, the measurement-error contribution to the covariance is $-\sigma_\varepsilon^2$. These effects can mimic key signatures originally interpreted as subdiffusion. The available analyses do not distinguish this artifact from genuine intrinsic subdiffusion convincingly enough to support the manuscript's central experimental claim.

The manuscript PDFs are retained as historical research documents and contain statements that **no longer reflect our current level of confidence** in the experimental interpretation. The theoretical derivations, model assumptions, and numerical implementations are presented for independent examination rather than as independently validated conclusions.

## Repository contents

- `manuscript.pdf` — original research manuscript (archived version).
- `supplementary_material.pdf` — supporting calculations and figures.
- `code/` — model simulation and figure-generation scripts.

## Citation

If you use the theoretical model, statistical-bias analysis, or code, please cite the **specific version or commit** of this repository, for example:

> Wei, J., Yan, Y., and Lin, J. (2026). *Subdiffusive Random Growth of Bacterial Size* [unpublished research manuscript and code archive]. GitHub, repository URL and version/commit.

Such a citation acknowledges the archived theoretical or computational work; it should **not** be used as evidence that intrinsic subdiffusion in bacterial growth was experimentally demonstrated.

Corrections, independent checks, and constructive discussion are welcome.
