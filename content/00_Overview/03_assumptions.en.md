---
title: Assumptions
weight: 3
---

## Assumptions

We assume that you have:
* a basic understanding of R and RStudio, and of metabolomics in general
* access to the internet and remote access to your raw data
* used Waters mass spectrometers and MassLynx software to obtain your data (although many steps in the workflow will be applicable to other instruments)
* you have a sample list from MassLynx and that you can provide your own treatment information (metadata, though our code can help format this)
* your files will be names with unique "Filename"s, ideally in the format of the following example:

<br>

- `experiment-identifier_001.raw`
- `experiment-identifier_002.raw`
- `experiment-identifier_003.raw`

<br>

(you may have technical replicates, each with their own .raw file. This is dealt with in the documentation)

### Extra assumptions for specific mass spectrometry approaches

* If you wish to analyse LC-MS data, you will need to sign up for an [XCMSonline/ METLIN account](https://xcmsonline.scripps.edu/register.php) and have a working password (this can take a few days to activate so sign up ASAP)
* We assume that if you have direct injection MS data, it has been run using and autoinjection system (and this is dealt with in the documentation)

