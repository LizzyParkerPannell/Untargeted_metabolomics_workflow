# Untargeted Metabolomics Workflow

Code in this repository can help with processing untargeted metabolomics of e.g. plant secondary metabolites or E.coli metabolites. The [workflow](https://untargeted-metabolomics-workflow.netlify.app/00_overview/05_workflow-diagram/) relies on existing open source tools including [XCMSonline](https://xcmsonline.scripps.edu/landing_page.php?pgcontent=mainPage) (for LCMS data), an [in-house macro]() from Overy *et al.* 2005 (for MALDI or DI-MS data), [MassUp](https://www.sing-group.org/mass-up/quickstart) or [MALDIquant](https://strimmerlab.github.io/software/maldiquant/) (for MALDI data).

The code can prepare a peak intensity table which is suitable for undirected (PCA) and directed (OPLS-DA) analysis using Metabolanalyst, R or SIMCA-P+ (proprietary).

### Citation and contact
For now please cite this github repository if you use the code (https://github.com/LizzyParkerPannell/Untargeted_metabolomics_workflow).

A manuscript (currently under review) providing ovierview of the LCMS workflow is available at:
> Parker, Ε.J.; Billane, K.C.; Austen, N.; Cotton, A.; George, R.M.; Hopkins, D.; Lake, J.A.; Pitman, J.K.; Prout, J.N.; Walker, H.J.; Williams, A.; Cameron, D.D. Untangling the Complexities of Processing and Analysis for Untargeted LC-MS Data Using Open-source Tools. Preprints 2023, 2023020056 (doi: 10.20944/preprints202302.0056.v1).

#### Contribution credits

Elizabeth Parker<sup>1❋</sup>, 
Kathryn Billane<sup>2❋</sup>, 
James Pitman<sup>3</sup>,
James Prout<sup>3</sup>,
David Hopkins<sup>5</sup>, 
Alex Williams<sup>5</sup>,
Heather Walker<sup>4</sup>,
Rachel George<sup>4</sup>,
Duncan Cameron<sup>6</sup>
.

❋ EP and KB are grateful to the University of Sheffield for “Unleash your data and software funding” that facilitated documentation of this workflow

1. EP planned and coordinated the project, wrote the R codes, contributed to writing, collated the documents
2. KB developed E. coli protocols, contributed to writing and collating documentation
3. JP and JP contributed to writing documents, tested workflow, contributed to R codes
4. HW and RG contributed protocols and guides to in-house tools, tested workflow, contributed to project planning
5. DH, AW tested workflows and R codes, contributed to project planning and aims
6. DC contributed to project planning and aims, supported the project with resources

#### Acknowledgements

With thanks to Harry Wright, Rachel George, Sophia van Mourik, Anne Cotton and Erika Hansson for their feedback.

## A note on experimental structure

A lot of the difficulties in analysis and/ or workflows come from the complexities of experimental structure. A lot of terms are used interchangeably in different contexts. Most tools for untargeted metabolomics are set up for 1 factor analysis with two or three levels e.g. 
- case vs control
- wild-type vs transgenic line
- Strain 1 vs strain 2 vs strain 3
    
However, we quite often have more complex experimental designs when coming from other fields e.g.
- 2 factor with two or more levels in each such as +/- treatment for 2 strains
- Time course for 1 or 2 factors such as +/- treatment for 2 strains over three time points
    
Before you start, think about the following questions and make a note of what you’re expecting in terms of which groups of metabolite fingerprints could be similar and which could be different to each other. I don’t mean hypothesise but more, think logically about what you’re asking in your analysis and how your data will be grouped.

- What are your biological replicates and are they independent of each other (or have you resampled the same organism/ population multiple times)?
- Do you have technical replicates (was each extract run through the MS multiple times)?
- Do you want/ need any QC samples, or analytical standard samples?
- If you have more than one treatment, or lots of meta-data, get organised. What groupings do you need to use to ask the questions you want answers to?
