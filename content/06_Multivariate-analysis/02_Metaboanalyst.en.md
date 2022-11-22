---
title: Metaboanalyst
weight: 2
---

## Using Metaboanalyst for multivariate analysis

Metaboanalyst is an online platform on which you can load, normalize, analyse and visualise your untargeted metabolomics data. Be careful though - there is a strong emphasis on detailed stats that are more appropriate for targeted analyses.

> Metaboanalyst is interoperable with R - you can access the code with the button at the top left of the Results page

We will not provide a lot of details here because the [tutorials and documentation for Metaboanalyst](https://www.metaboanalyst.ca/MetaboAnalyst/docs/Tutorials.xhtml) are very good.

If you have created your peak table using our code for [MALDI/DI-ESI-MS](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow/blob/38e41b65371523c1e8052f0697a3ff59fe928c2d/05_tidy_data_from_XCMS-online.R) or [LC-ESI-MS](https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow/blob/38e41b65371523c1e8052f0697a3ff59fe928c2d/05_tidy_data_from_XCMS-online.R), then you will now have the files formatted ready for use in Metaboanalyst.

If your experiment included just one treatment (or variable) e.g. a case vs control, then you can use [Statistical analysis one factor](https://new.metaboanalyst.ca/MetaboAnalyst/upload/StatUploadView.xhtml) and upload the file named:
- `"Untargeted_metabolomics_workflow\Tidy_data\MALDI_Data_for_metaboanalyst_1factor.csv"` or `"Untargeted_metabolomics_workflow\Tidy_data\XCMS_Data_for_metaboanalyst_1factor.csv"`

If your experiment included multiple treatments (or variables), batch information or other metadata, then you need to use [Statistical analysis metadata table](https://new.metaboanalyst.ca/MetaboAnalyst/upload/MultifacUploadView.xhtml) and upload two files:
- `"Untargeted_metabolomics_workflow\Tidy_data\MALDI_Data_for_metaboanalyst_2factor.csv"` or `"Untargeted_metabolomics_workflow\Tidy_data\XCMS_Data_for_metaboanalyst_2factor.csv"`
- `"Untargeted_metabolomics_workflow\Tidy_data\MALDI_metadata_for_metaboanalyst.csv"` or `"Untargeted_metabolomics_workflow\Tidy_data\XCMS_metadata_for_metaboanalyst.csv"`

On the upload page, make sure to select "Peak Intensities", "Samples in rows" and to add the relevant .csv files.

