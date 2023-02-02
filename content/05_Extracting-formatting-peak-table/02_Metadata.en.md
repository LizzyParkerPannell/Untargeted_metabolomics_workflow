---
title: Metadata
weight: 2
tags: ["MALDI", "DIMS", "LCMS"]
---

> :warning: the following is a repeat of [Samples & Treatments](https://untargeted-metabolomics-workflow.netlify.app/03_conversion-to-open-format/05_samples-treatments/) 
which will help you get your metadata in order ready for analysis.

## Nice neat metadata for analysis

Before we go any further, it is worth making sure we have all the sample and treatment information we need to make our analysis repeatable (by ourselves or someone else e.g. a reviewer).

More metadata is required for submitting to a repository but we will cover that later. For now, this is what you will need to perform an untargeted analysis.

You need to create two `.csv` files (you can do this in excel, R, google sheets, whatever you like) as long as the order and headings of the columns are as follows:

For you `samplelist.csv` you need the following columns which can be obtained from your `MassLynx Sample List`:
1. **"Filename"** : this is the label you have assigned to each biological sample in MassUP.
2. **"Filetext"** : this is the name you have manually added to the metadata of that sample in MassLynx[^1]
3. **"MSFile"** or an equivalent column that contains either "pos" or "neg" within it
Any other columns will be ignored in this file

{{< figure src="/images/samplelist.png" >}}

For your `treatments.csv` you need at least two columns (but can have as many as you like):
1. **"Filetext"** : this must contain all the distinct values of Filetext from samplelist.csv
2. **"Variable1"** : you can call this column whatever you like (but avoid spaces, instead use "-" or "_"). If you have compared a wild-type to a control for example, you might call this column "treatment" and fill it with "WT" and "C"
2. **"Variable2"** etc : further variables that you wish to analyse. This may include batch identifiers (for example if you have many samples and they were run over multiple days), treatments or environmental variables

{{< figure src="/images/treatments.png" >}}

Keep these in a folder with all of the individual output folders from MassUp, as well as your R project, R script, and a folder called Tidy_data. These should be the only files in this folder aside from possibly an Rhistory file. An example of how these should be layed out is shown below.

[^1]: You can find this at `$$ SampleID:` in the `_HEADER.txt` file of the original `.RAW` folder if you need to


