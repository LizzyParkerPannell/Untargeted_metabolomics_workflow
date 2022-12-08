---
title: Multivariate analysis
weight: 1
---

We want to ask two key questions when analysing a new untargeted metabolomics dataset:

> :question: Are the metabolomic fingerprints of our classes (treatment groups) different from eachother?


> :question: Which features of the metabolomic fingerprint is causing them to be different from eachother?

To answer the first question we will use a Principal Component Analysis (PCA) which is an undirected approach (so we don't tell the model which class each of the samples belongs to). A PERMANOVA can be used to give some corroboration of patterns observed in the PCA. If we find clear differences between classes in the PCA, then we can look at pair-wise differences between class (treatment groups) using an OPLS-DA (this stands for orthogonal projections of latent structures - directed analysis).

> :warning: An OPLS-DA will accentuate the differences between any two classes, to the point where you can often "find" what looks like a strong difference between two randomly assigned classes. For this reason it is very important to run a PCA first and to have good biological justification for why you are comparing two particular classes.

Here we will show how to perform these analyses using a free online platform (Metaboanalyst) and how to run some alternative code in R. The advantage of running the code is that you can integrate it with other analyses (and formatting for figures etc) but Metaboanalyst guides you through the process and has some handy sense-checks along the way.

It is also possible to analyse the same peak tables using SIMCA (Umetrics) or other proprietary softwares. However, it is much harder (and more costly) to use these remotely, and it is harder to document your analysis for sharing with other researchers.

