---
title: Proteowizard
weight: 1
---

We want to convert our .RAW files (which each contain lots of data and metadata about the run in separate files and are BIG). .RAW files are specific to Waters software and will not work with many open source tools. We will convert them to .mzML which is the standard open data format for mass spectrometry[^1]. 

## File conversion using Proteowizard

Download the [Proteowizard software](https://proteowizard.sourceforge.io/) and install. Within Proteowizard are two applications:

- SeeMS
- MSConvert

SeeMS is really useful for viewing chromatograms and spectra when you don't have access to proprietary software like MassLynx.

### MSConvert

> :warning: Depending on which type of MS you have used, we will use different settings/ parameters in MSConvert, so click through or use the menu on the left for instructions to complete this step.

[^1]:**Martens *et al.* (2011).** mzML—a Community Standard for Mass Spectrometry Data. Mol. Cell. Proteomics DOI: https://doi.org/10.1074/mcp.R110.000133 


## Alternative conversion tools

Proteowizard is widely used but there are a number of other tools available (particularly for those who want to run all processing in R or Python). Contributions of guides to expand these options would be gratefully received through [github](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow).

- [Omigami for R and Python](https://www.omigami.com/)
- [pymzML](https://pymzml.readthedocs.io/en/latest/intro.html) and [pyMassSpec](https://pymassspec.readthedocs.io/en/master/)
