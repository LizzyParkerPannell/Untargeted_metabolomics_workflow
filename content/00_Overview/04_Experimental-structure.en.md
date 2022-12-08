---
title:
menuTitle: Experimental Structure
weight: 4
---

## Experimental structure

A lot of the difficulties in analysis and/ or workflows come from the complexities of experimental structure. A lot of terms are used interchangeably in different contexts. Most tools for untargeted metabolomics are set up for 1 factor analysis with two or three levels e.g.

* case vs control
* wild-type vs transgenic line
* Strain 1 vs strain 2 vs strain 3

However, we quite often have more complex experimental designs when coming from other fields e.g.

* 2 factor with two or more levels in each such as +/- treatment for 2 strains
* Time course for 1 or 2 factors such as +/- treatment for 2 strains over three time points

> :warning: Before you start, think about the following questions and make a note of what you’re expecting in terms of which groups of metabolite fingerprints could  be similar and which could be different to each other. 

I don’t mean hypothesise but more, think logically about what you’re asking in your analysis and how your data will be grouped.

* What are your biological replicates and are they independent of each other (or have you resampled the same organism/ population multiple times)?
* Do you have technical replicates (was each extract run through the MS multiple times)?
* Do you want/ need any QC samples, or analytical standard samples?
* What groupings do you need to use to ask the questions you want answers to?

> :bulb: Get your meta-data (e.g. treatment information) organised early. 
