---
title: METLIN
weight: 3
---

## Using METLIN to help with annotation

What you should have: A list of masses of interest from metaboanalyst or mass bins of interest and the detected masses within those bins from the macro.
The rest of this stage is not automated and will be the stage that takes the longest, so make sure you’re fairly happy with the preceding analysis before you commit time to this.

Metlin: https://metlin.scripps.edu/
Log in > Simple search

Enter your mass of interest

Tolerance: 30 PPM 
This could be altered depending on if you’re getting lots of results or not many, but the lower the PPM the better __link to ppm paper

Charge: positive or negative depending on which mode your data was run in.

Adducts: M+H, M+NH4, M+Na, M+K

For biological samples I’d recommend choosing to see only those samples that have KEGG IDs associated with them (from the KEGG ID drop down list). This is likely to remove many synthetic chemicals that are unlikely to appear in organism metabolisms naturally and reduces the number of options you need to go through.
Create a spreadsheet of these results. Detected and accurate mass, ppm, associated sample, Compound name and KEGG ID are particularly important to include.
