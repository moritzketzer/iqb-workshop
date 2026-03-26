# Introduction to Graphical Causal Inference

FDZ Frühjahrsakademie / Spring Academy 2026

**Workshop Website**: <https://moritzketzer.github.io/iqb-workshop/>

| | |
|---|---|
| **Lecturer** | Moritz Ketzer |
| **Part 1** | Monday, 09.03.2026, 9:00–13:00 h |
| **Part 2** | Tuesday, 10.03.2026, 9:00–13:00 h |

## Abstract

An accessible introduction to graphical approaches to causal inference. In Part 1, we build up the basic concepts of causal reasoning. Starting from Simpson's Paradox, we learn what distinguishes association from causation and how to formalize causal reasoning with Pearl's structural causal models (SCMs) and directed acyclic graphs (DAGs). We express interventions using the do-operator and turn informal scientific questions into precise causal quantities. We then introduce the graphical language of confounders, colliders, mediators and backdoor paths, and use them to decide when a causal question can be answered from observational data alone. We practice recognizing these structures in hands-on exercises — identifying adjustment sets by visual inspection, using the online tool DAGitty, and working through a "Causal Quartet" that shows how the same data can yield opposite conclusions depending on the underlying causal structure. In Part 2, we walk through a complete causal roadmap from question to identification. We then turn to treatment effect heterogeneity — what happens when the effect is not the same for everyone? — and extend the framework to multilevel data. Drawing on my current research, we develop causal graphs for cross-sectional multilevel models, show how structured heterogeneity in variance and slopes induces confounding that standard path diagrams cannot express, and demonstrate how common estimators (including two-way fixed effects) can produce sign-reversed estimates when effects are heterogeneous.

## Contents

### Part 1 (4 hours): Foundations of graphical causal inference

- Welcome and introduction round
- Why bother with causal inference?
    - Spurious correlations and Simpson's Paradox (kidney stones)
    - Description, prediction, and explanation as distinct goals
    - The ladder of causation: association, intervention, and counterfactuals
- Introduction to structural causal models (SCMs)
    - Structural equations and directed acyclic graphs (DAGs)
    - The do-operator and graph surgery
    - Defining causal estimands (ATE)
    - Brief comparison to the Rubin–Holland causal model (potential outcomes)
- The three elemental structures
    - Fork (confounder), chain (mediator), collider
    - Open vs. blocked paths and d-separation
    - Identifying backdoor paths and valid adjustment sets
- Exercise: The Causal Quartet
    - Same data, four DAGs, opposite conclusions — which variables should we adjust for?

### Part 2 (4 hours): From averages to heterogeneity — multilevel causal graphs

- The Causal Roadmap: from question to identification
    - Running example: "Does sharing data openly cause more citations?"
    - Walking through each step: theorize, define question, specify estimand, draw DAG, identify
    - Exercise: DAGitty — draw and analyze your own DAG
    - DAG Gallery: participants share and discuss their graphs
- Treatment effect heterogeneity
    - When the ATE hides conflicting individual effects (Gelman's causal quartets)
    - Interaction terms in SCMs and conditional average treatment effects (CATEs)
- From path diagrams to causal graphs for multilevel models
    - Common path diagram conventions and their limitations
    - Directed acyclic mixed graphs (DAMGs)
    - Plate notation for multilevel DAGs
    - Multilevel regression ↔ mixed-model ↔ structural form equivalence
- Confounding from structured heterogeneity
    - Group-mean centering and the Mundlak device
    - Variance heterogeneity and location-scale models
    - Exercise: Multilevel Confounding — which estimators recover the true causal effect?
- When estimators break: implicit weighting and sign reversal
    - Multilevel estimates as weighted least squares in disguise
    - Negative weights in two-way fixed effects (TWFE)
    - Applied example: Medicaid expansion and preterm birth

## Further Reading

A curated, topical reading list is available on the [workshop website](https://moritzketzer.github.io/iqb-workshop/further-reading.html).

## Prerequisites

Basic familiarity with quantitative methods is required (introductory statistics and linear regression at the level of interpreting coefficients and covariates). Prior knowledge of causal inference, directed acyclic graphs (DAGs), or structural equation modeling is not required. Familiarity with multilevel/mixed models is helpful for Part 2 but not a prerequisite.

## Literature

**Short conceptual pieces (framing the "C-word" and the roadmap)**

Ahern, J. (2018). Start With the "C-Word," Follow the Roadmap for Causal Inference. *American Journal of Public Health*, *108*(5), 621. <https://doi.org/10.2105/AJPH.2018.304358>

Hernán, M. A. (2018). The C-Word: Scientific Euphemisms Do Not Improve Causal Inference From Observational Data. *American Journal of Public Health*, *108*(5), 616–619. <https://doi.org/10.2105/AJPH.2018.304337>

**The popular scientific book (also available on audible)**

Pearl, J., & Mackenzie, D. (2018). *The book of why: The new science of cause and effect* (First edition). Basic Books.

**Introduction to graphical causal models in psychology**

Rohrer, J. M. (2018). Thinking clearly about correlations and causation: Graphical causal models for observational data. *Advances in Methods and Practices in Psychological Science*, *1*(1), 27–42.

Bailey, D. H., Jung, A. J., Beltz, A. M., Eronen, M. I., Gische, C., Hamaker, E. L., Kording, K. P., Lebel, C., Lindquist, M. A., & Moeller, J. (2024). Causal inference on human behaviour. *Nature Human Behaviour*, *8*(8), 1448–1459.

**Special topics (causal inference in clustered and multilevel data)**

Rohrer, J. M., & Murayama, K. (2023). These Are Not the Effects You Are Looking for: Causality and the Within-/Between-Persons Distinction in Longitudinal Data Analysis. *Advances in Methods and Practices in Psychological Science*, *6*(1), 251524592211408. <https://doi.org/10.1177/25152459221140842>

Gische, C., West, S. G., & Voelkle, M. C. (2021). Forecasting Causal Effects of Interventions versus Predicting Future Outcomes. *Structural Equation Modeling: A Multidisciplinary Journal*, *28*(3), 475–492. <https://doi.org/10.1080/10705511.2020.1780598>

Ketzer, M., Gische, C., & Voelkle, M. C. (2025). From path diagrams to causal graphs: A structural causal perspective on cross-sectional multilevel models. *Structural Equation Modeling: A Multidisciplinary Journal*. Advance online publication. <https://doi.org/10.1080/10705511.2025.2592071>

**Introductory and foundational textbooks for deeper study**

Pearl, J. (2009). *Causality: Models, Reasoning, and Inference* (2nd ed.).

Pearl, J., Glymour, M., & Jewell, N. P. (2016). *Causal Inference in Statistics: A Primer* (1st edition). Wiley.

Imbens, G. W., & Rubin, D. B. (2015). *Causal Inference for Statistics, Social, and Biomedical Sciences*.

Morgan, S. L., & Winship, C. (2015). *Counterfactuals and causal inference: Methods and principles for social research* (Second Edition). Cambridge University Press.

Hernán, M. A., & Robins, J. M. (2020). *Causal Inference: What If*. Boca Raton: Chapman & Hall/CRC.

## Software

- A modern web browser to use [DAGitty](https://dagitty.net), an online tool for drawing and analyzing causal DAGs.
- R exercises were run on a shared RStudio Server provisioned for the workshop (see `server/` for the NixOS configuration).