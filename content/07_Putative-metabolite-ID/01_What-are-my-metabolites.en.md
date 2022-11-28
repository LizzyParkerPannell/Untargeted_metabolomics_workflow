---
title: What are my metabolites?
weight: 1
---

## What are my metabolites?

> :warning: Sadly this stage is not automated and will be the stage that takes the longest, so make sure you’re fairly happy with the preceding analysis before you commit time to this.

Annotating metabolomic features is challenging - there are some automated annotations included with e.g. `XCMS` that rely on the `CAMERA` package amongst others. However, these often struggle with unusual experimental structures and/ or large datasets, "unusual" (read: non human) metabolites etc. So here we have reduced the number of metabolomic features we want to annotate to just those that are causing a significant (in terms of reliability *and* magnitude) difference between two classes of samples.

To understand what these features might be, we will compare the m/z (or m/z with RT) values highlighted by our multivariate analysis with databases of reference m/z and with experimental data from the literature (usually available in the paper or in a repository like [MetaboLights]"https://www.ebi.ac.uk/metabolights/search?").

*At this point you should have a list of metabolomic features of interest with m/z to min. 4 decimal places*

