# Subdiffusive Random Growth of Bacterial Size — Research Archive

> **Important scientific note (October 2026).** A previous version of this study is publicly available on [bioRxiv](https://doi.org/10.64898/2026.03.19.712816). This GitHub repository contains a **more recent manuscript version**, supplementary materials, and simulation/figure-generation code. **Neither version establishes that intrinsic bacterial growth is subdiffusive.** Following peer review, we recognized that frame-to-frame cell-size measurement errors offer an alternative explanation for key experimental observations, and this possibility has not been adequately ruled out. In particular, the reported experimental exponent near 0.25 and the attribution of that exponent to cell-wall viscoelasticity should **not** be treated as established experimental conclusions.

## Background and purpose

The earlier preprint, [*Subdiffusive random growth of bacteria*](https://doi.org/10.64898/2026.03.19.712816) (Wei, Yan, and Lin, bioRxiv, 2026), provides a public record of this project. The manuscript archived here, titled *Subdiffusive random growth of bacterial size*, reflects later revisions and may differ from the bioRxiv version. The papers are shared for transparency and historical context; we are not currently pursuing further journal submission.

We are releasing these materials because parts of the theoretical and computational work may be useful independently of the unresolved experimental interpretation:

- **Viscoelastic stochastic-growth model.** A collection of Voigt elements with broadly distributed relaxation times provides a mechanism by which microscopic white-noise forcing can lead to temporally correlated, subdiffusive macroscopic fluctuations. Under the stated model assumptions and in the appropriate asymptotic regime, the predicted scaling exponent is $\alpha=3-2\beta$ for $1<\beta<3/2$.
- **Statistical-bias analysis.** Analytical arguments and simulations explore apparent acceleration or deceleration in estimated cell growth rates when observations are conditioned on relative cell-cycle age, size, or elapsed time, including first-passage and survival-selection effects.
- **Code and figure-generation materials.** Scripts are organized in the repository for inspection and reuse, subject to the repository license and any third-party data restrictions. Data-dependent figures may require access to the unpublished experimental measurements.

These theoretical results describe the specified models; they are **not experimental validation** of intrinsic subdiffusion in bacteria.

## Experimental data provenance

The experimental cell-growth trajectories analyzed in this project come from **unpublished single-cell data associated with** the following published study:

> Taheri-Araghi, S., Bradde, S., Sauls, J. T., Hill, N. S., Levin, P. A., Paulsson, J., Vergassola, M., and Jun, S. (2015). *Cell-Size Control and Homeostasis in Bacteria*. **Current Biology, 25**, 385–391. https://doi.org/10.1016/j.cub.2014.12.009

The source study is published, but **the specific raw experimental dataset used for our analysis was not publicly released as part of that publication**. These are data originating from the earlier study, not experiments newly conducted for this project. This archive contains analyses of those measurements alongside theoretical and computational work. Availability of analysis or plotting code should **not** be taken to imply that the underlying unpublished data are openly available or licensed for redistribution. Reproducing data-dependent figures may require separate authorized access to the original measurements.

## Why the experimental interpretation is unresolved

Let the measured logarithmic cell volume be $x_{\mathrm{obs}}(t)=x_{\mathrm{true}}(t)+\varepsilon(t)$. If the frame-to-frame measurement errors $\varepsilon(t)$ are independent, with variance $\sigma_\varepsilon^2$, and independent of the true growth process, then for a nonzero time lag $\Delta t$:

$$
\mathrm{Var}[x_{\mathrm{obs}}(t+\Delta t)-x_{\mathrm{obs}}(t)]
=\mathrm{Var}[x_{\mathrm{true}}(t+\Delta t)-x_{\mathrm{true}}(t)]
+2\sigma_\varepsilon^2.
$$

The error also contributes $-\sigma_\varepsilon^2$ to the covariance of consecutive, non-overlapping single-frame growth increments. Thus, ordinary accumulating growth fluctuations combined with nonaccumulating measurement noise may generate both an apparently low scaling exponent over a short time window and a strong negative one-frame-lag correlation. Our analysis did not distinguish this alternative convincingly from intrinsic subdiffusion.

**Please read the manuscript and figures in light of this limitation.** Some experimental claims in the archived PDFs no longer reflect our current confidence. The mathematical derivations and simulations are offered for independent checking, not with a guarantee that every claim or implementation is correct.

## Repository structure

| Path                      | Contents                                                     |
| ------------------------- | ------------------------------------------------------------ |
| `main/`                   | Main-manuscript materials, including the later version       |
| `SM/`                     | Supplemental-material files                                  |
| `fig1/`, `fig2/`, `fig3/` | Materials associated with the three main figures; some analyses depend on unpublished experimental data |
| `figS/`                   | Supplemental-figure materials                                |
| `LICENSE`                 | Repository license                                           |

## Reproducibility

The repository contains simulation and figure-generation code organized into `fig1/`, `fig2/`, `fig3/`, and `figS/`.

The theoretical models and numerical simulations can be studied independently of the experimental data. However, some figure-generation scripts depend on unpublished experimental measurements associated with Taheri-Araghi et al. (2015), which are **not included in this repository**. Therefore, not all experimental figures can be reproduced using the publicly available files alone.

The code is provided for inspection, reuse, and independent verification. Reproducing specific results may require adapting file paths, dependencies, and numerical settings.

## Citation

If you find the theoretical model, mathematical derivations, statistical-bias analyses, or simulation code useful, please cite this GitHub repository, preferably using a specific release or commit.

The earlier version of this manuscript is available on bioRxiv ([DOI: 10.64898/2026.03.19.712816](https://doi.org/10.64898/2026.03.19.712816)) as a historical record. However, its central experimental claim of intrinsic subdiffusive bacterial growth is not sufficiently supported, as the observed signatures may be explained by measurement noise.

We therefore recommend citing this repository for its theoretical and methodological contributions rather than citing the bioRxiv preprint as evidence for experimental subdiffusion.

Comments, corrections, and independent verification are welcome.

