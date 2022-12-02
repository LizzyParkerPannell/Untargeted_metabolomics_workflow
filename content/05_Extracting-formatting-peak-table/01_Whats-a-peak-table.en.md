---
title: What's a peak table?
weight: 1
---

A peak table is an data frame made up of an aligned set of spectra with concentration or intensity values against a set of features (m/z or m/z with retention time).

It will still be a big file but way smaller than your .mzML files.

Here is an example of part of such a peak list:

{{< figure src="/images/" >}}

Different downstream tools for multivariate statistics will require the peak table in slightly different formats so the code we have included in this guide will help you format for
some common uses (Metaboanalyst 1factor and 2factor peak tables) as well as helping you format your treatment information as metadata so that you can interrogate your peak table.