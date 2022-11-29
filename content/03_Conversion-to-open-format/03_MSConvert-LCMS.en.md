---
title: MSConvert LCMS
weight: 4
tags: ["LCMS"]
---

## Convert LC-ESI-MS data to open format

Open MSConvert

> :warning: If you are using a remote drive (e.g. google drive or onedrive) with a slow connection it is worth doing your conversion in small batches so you can check the file size as you go - if you are seeing big discrepencies you need to go back and check the sizes of your original files. Some files may need re-converting if your connection times out during the process.

File: "Browse" > Select .RAW folders to convert
{{< figure src="/images/MALDI_convert_browse_raw.png" >}}

Output Directory: Specify an output folder using “Browse”
{{< figure src="/images/MALDI_convert_destination.png" >}}

Options: Output File > mzML

Filters: 
1. FIRST select "peakPicking" (from drop down menu) > "Vendor(does not work for UNIFI, and it MUST be the first filter!)" *This is your centroiding step - a form of file compression*
2. select "subset" (from drop-down menu) > "scanEvent" = 1-1 and select “polarity = positive” or "polarity = negative" depending on your MS run (and click “add”)
{{< figure src="/images/LCMS_convert_options.png" >}}

Select "Start" (bottom right)
{{< figure src="/images/LCMS_convert_start.png" >}}

> :bulb: These data will now be "centroided" meaning the peaks that were in wave-form ("profile") before, are now a series of "sticks". Technically this is the first stage of processing and you must report it in your methods

Check the size of .mzML files - should all be similar. Reconvert any that look small. If you consistently have some that are much smaller, it is worth checking whether these ran properly or whether there were any issues copying or converting the files (such as intermittent internet connection).
{{< figure src="/images/LCMS_SeeMS_select.png" >}}
{{< figure src="/images/LCMS_SeeMS_mzml.png" >}}

> :warning: If you have any big gaps or empty tables when you look at your chromatograms/ spectra in SeeMS, then you should go back and redo the conversion.
