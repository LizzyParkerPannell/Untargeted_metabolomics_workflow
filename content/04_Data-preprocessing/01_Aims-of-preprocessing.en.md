---
title: Aims of Pre-processing
weight: 1
---

## Aims of pre-processing data

Untargeted metabolomics datasets are huge! To get from huge .mzML to a tractable peak table that we can interrogate with multivariate statistics, we have to do a little bit of looking after our data.

Depending on the MS approach, different stages are involved but they broadly fall into:

- baseline correction and/ or noise reduction (estimating what part of the detected intensity is your sample and "cleaning away" or adjusting the spectra to show only the signal we believe to be associated with the sample)
- normalization and/ or standardization (these can mean a range of different things to different people but broadly cover accounting for differences in sample volume or concentration or total intensity of the signal)
- grouping and peak picking (wave-form algorithms are used to determine which parts of the spectra constitute separate peaks and what their m/z value is)
- alignment or peak matching (looking across the samples to see whether peaks with slightly different m/z values might actually be the same peak so that samples can be compared more reliably)

> :bulb: By the end of this stage, we will have the processed data we need to create one table with all the m/z and intensity values we need for analysis (although we will actually make the peak table itself in [stage 5](https://untargeted-metabolomics-workflow.netlify.app/05_extracting-formatting-peak-table/))