---
title: MSConvert DIMS
weight: 3
tags: ["DIMS"]
---

## Convert direct injection ESI-MS data to open format

> :bulb: When metabolome fingerprinting using DI-ESI-MS, we autoinject the sample over a period of time. We only want the scans from a certain range in the chromatogram - the range where the sample is.

Below is an example of the chromatograms we get from DI-ESI-MS:

{{< figure src="/images/DIMS_example-chromatogram.png" >}}

> :warning: In this example, the "troughs" or "gaps" in the chromatogram are where the optional lockmass calibration is performed during the run

Along this chromatogram there is a spectrum for every second (that rate is changeable but default is usually 1scan/sec). 

The peak starting at 0.3mins (20 seconds) shows when the sample was injected into the flow. 

The flat line before the peak is the signal intensity of the background noise, and you can see that at the tail end of the chromatogram the signal is back down to that level as the sample has been washed through. 

We only want to work with the spectra around the sample peak, once it has all been injected the signal steadily drops as the sample is washed out. 

**The image below shows the range of the chromatogram we want (blue) and the range we want to remove (red):**

{{< figure src="/images/DIMS_example_shaded-area.png" >}}

---

### Checking the scan range you want

Open SeeMS, and select a .RAW file from early in your run. This will load:
- a chromatogram
- the first spectrum from that run
- a list of the spectra 

{{< figure src="/images/DIMS_select-scans_SeeMS.png" >}}

Identify where your sample peak is in the chromatogram and choose a scan range that covers this peak

{{< figure src="/images/DIMS_highTIC_select-scans.png" >}}

In the example above the peak is centred on 0.5mins (30 seconds). Looking at the spectra list given below the chromatogram we can see that the TIC is high from spectra 17-48 so we would choose a 20 spectra range from within these boundaries (here I have selected 17-37). 

> :warming: Scan range should be the same throughout the run. 20 scans is the minimum number, you can do more if you have a much wider peak. Before you decide on your spectra range, check that chromatograms from later in the run also fit in this range. 
Over long runs there can be a bit of a lag build up and samples may be injected a couple of seconds later, shifting the whole peak to the right slightly. 
So check that your chosen range fits chromatograms from the start, middle and end of the run. 

---

### File conversion

