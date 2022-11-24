---
title: Workflow diagram
weight: 5
---
This diagram summarises the entire workflow and can help you make decisions about which tools are most relevant to your analysis based on the type of Mass Spectrometry you have used.

The diagram is split into sections which correspond to the stages of the guide (see sidebar menu).

<html lang="en">
  <head>
    <meta charset="utf-8" />
  </head>
  <body>
    <pre class="mermaid">
  graph TD

    subgraph S01[ ]
    title_S01[Stage 1 - Metabolite Extraction]

    A{Plants or bacteria} -->|Plants| B[\Quenching, extraction & phase separation/]
    A --> |Bacteria| C[\Growth & isolation of cells/] --> B
    
    classDef red fill:#D53E4F, stroke:#D53E4F;
    class A,B,C red;
    end
    
    subgraph S02[ ]
    title_S02[Stage 2 - Data Acquisition]

    D{Which MS?} --> E[MALDI]
    D --> F[DI-ESI-MS]
    D --> G[LC-ESI-MS]
    D --> H[GC-ESI-MS] --> I>Standardized GCMS workflow]
    E --> J[/.RAW files from MassLynx/]
    F --> J
    G --> J

    classDef orange fill:#F46D43, stroke:#F46D43;
    class D,E,F,G,H,I,J orange;
    end

    B --> D

    subgraph S03[ ]
    title_S03[Stage 3 - Data conversion to open format]

    K[Convert data\n Proteowizard > MSConvert\n * scanEvent\n * polarity]-->|MALDI|N[/.mzML open format\n profile/]
    L[Convert & compress data\n Proteowizard > MSConvert\n * Scan range\n * scanEvent\n * polarity]-->|DI-ESI-MS|O[/.mzML open format\n profile, selected scans/]
    M[Convert & compress data\n Proteowizard > MSConvert\n * peakPicking\n * scanEvent\n * polarity]-->|LC-ESI-MS|P[/.mzML open format\n centroid/]

    click K "https://untargeted-metabolomics-workflow.netlify.app/03_conversion-to-open-format/02_msconvert-maldi/" _blank
    click L "https://untargeted-metabolomics-workflow.netlify.app/03_conversion-to-open-format/04_msconvert-dims/" _blank
    click M "https://untargeted-metabolomics-workflow.netlify.app/03_conversion-to-open-format/03_msconvert-lcms/" _blank

    classDef pale_orange fill:#FDAE61, stroke:#FDAE61;
    class K,L,M,N,O,P pale_orange;
    end

    J -->|MALDI|K
    J -->|DI-ESI-MS|L
    J -->|LC-ESI-MS|M

    subgraph S04[ ]
    title_S04[Stage 4 - Data preprocessing]
    
    Q[MassUp or R to run\n MALDIquant\nbaseline correction, normalization, alignment, peak detection]
    R[XCMSonline or R to run\n XCMS\nPeak picking, RT correction, alignment, grouping]

    classDef yellow fill:#FEE08B, stroke:#FEE08B;
    class Q,R yellow;

    click Q "https://untargeted-metabolomics-workflow.netlify.app/04_data-preprocessing/02_processing-maldi/" _blank
    click R "https://untargeted-metabolomics-workflow.netlify.app/04_data-preprocessing/03_processing-lcms/" _blank
    end

    N & O --> Q
    P --> R

    subgraph S05[ ]
    title_S05[Stage 5 - Extract & format peak table & metadata]
    
    S[Download each sample's .csv\n and tidy in R] --> U[/.csv peak table\n samples as rows, m.z as columns/]
    T[Download results folder\n and tidy in R] --> U
    U --- V[/.csv metadata\n sample, independent variable1 .../]
    
    classDef pale_yellow fill:#E6F598, stroke:#E6F598;
    class S,T,U,V pale_yellow;

    click S "https://untargeted-metabolomics-workflow.netlify.app/05_extracting-formatting-peak-table/02_peak-table_massup/" _blank
    click T "https://untargeted-metabolomics-workflow.netlify.app/05_extracting-formatting-peak-table/03_peak-table_xcmsonline/" _blank

    end
    
    Q --> S
    R --> T

    subgraph S06[ ]
    title_S06[Stage 6 - Multivariate analysis]
    direction TB
    
    W{Open source, online, \nlocal and/or proprietary?} -->|Open source\nlocal\nversion control with git|S09(pcaMethods & muma\n using R & RStudio)
    W -->|Open source\nonline\nsense checks|S10(Metaboanalyst)
    W -->|Proprietary\nlocal|S11(Proprietary software\n e.g. SIMCA by Umetrics)
    
    click S09 "https://untargeted-metabolomics-workflow.netlify.app/06_multivariate-analysis/03_r-for-pca-and-oplsda/" _blank
    click S10 "https://untargeted-metabolomics-workflow.netlify.app/06_multivariate-analysis/02_metaboanalyst/" _blank

    classDef pale_green fill:#ABDDA4, stroke:#ABDDA4;
    classDef empty_pale_green fill:honeydew, stroke:#ABDDA4;
    class W pale_green;
    class S09,S10,S11 empty_pale_green;

        subgraph S12[ ]
        direction TB
        A1[Load data and metadata] --> A2[Scaling & normalization] --> A3[Exploratory analysis\n PCA, PERMANOVA & interpretation] --> A4[Directed analysis where appropriate\n OPLS-DA & detailed stats]
        A4 --> A5[/List of features of interest\nm/z or m/z with RT/]
        A3 & A4 --> A6>Graphs & stats for reporting]
        class A1,A2,A3,A4,A5,A6 pale_green;
        end

    S09 & S10 & S11 --> A1

    end

    V --> W

    subgraph S07[ ]
    title_S07[Stage 7 - Putative metabolite identification]

    X[Use features of interest\n to search databases/repositories and literature\n e.g. METLIN, KEGG, PubChem, Cyc, MassBank]
    X --> Y[/Putative identities of metabolites\n responsible for differences between classes/]
    Y --> Z>Further MS to confirm IDs\n targeted, tandem or NMR] & Z1>Pathway analysis, enrichment analysis]
    
    classDef green fill:#66C2A5, stroke:#66C2A5;
    class X,Y,Z,Z1 green

    click X "https://untargeted-metabolomics-workflow.netlify.app/07_putative-metabolite-id/" _blank
    end

    A5 --> X

    subgraph S08[ ]
    title_S08[Stage 8 - Data archiving and reporting]
    
    B1{{Prepare data for\n submission to repository}} --> B2[Submit data to MetaboLights]
    Y & U & V & J -.-> B1
    B2 --> B3[Remember to cite tools used]

    classDef blue fill:#3288BD, stroke:#3288BD;
    class B1,B2,B3 blue
    
    click B1 "https://untargeted-metabolomics-workflow.netlify.app/08_data-archiving-citation/02_metabolights/" _blank
    click B2 "https://www.ebi.ac.uk/training/online/courses/metabolights-quick-tour/submitting-data-to-metabolights/" _blank
    end

    %% defining subgraph title node styling
    style title_S01 fill:white, stroke:#D53E4F, stroke-width:4;
    style title_S02 fill:white, stroke:#F46D43, stroke-width:4;
    style title_S03 fill:white, stroke:#FDAE61, stroke-width:4;
    style title_S04 fill:white, stroke:#FEE08B, stroke-width:4;
    style title_S05 fill:white, stroke:#E6F598, stroke-width:4;
    style title_S06 fill:white, stroke:#ABDDA4, stroke-width:4;
    style title_S07 fill:white, stroke:#66C2A5, stroke-width:4;
    style title_S08 fill:white, stroke:#3288BD, stroke-width:4;

    %% adding URL links (subgraph titles)
    click title_S01 "https://untargeted-metabolomics-workflow.netlify.app/01_metabolite-extraction/" _blank
    click title_S02 "https://untargeted-metabolomics-workflow.netlify.app/02_data-acquisition/" _blank
    click title_S03 "https://untargeted-metabolomics-workflow.netlify.app/03_conversion-to-open-format/" _blank
    click title_S04 "https://untargeted-metabolomics-workflow.netlify.app/04_data-preprocessing/" _blank
    click title_S05 "https://untargeted-metabolomics-workflow.netlify.app/05_extracting-formatting-peak-table/" _blank
    click title_S06 "https://untargeted-metabolomics-workflow.netlify.app/06_multivariate-analysis/" _blank
    click title_S07 "https://untargeted-metabolomics-workflow.netlify.app/07_putative-metabolite-id/" _blank
    click title_S08 "https://untargeted-metabolomics-workflow.netlify.app/08_data-archiving-citation/" _blank

    %% defining subgraph styling
    classDef subgraphstyle fill:white, stroke:white, stroke-width:0;
    class S01,S02,S03,S04,S05,S06,S07,S08,S12 subgraphstyle;

%% colors 
%% #D53E4F
%% #F46D43
%% #FDAE61
%% #FEE08B
%% #E6F598
%% #ABDDA4
%% #66C2A5
%% #3288BD

</pre>
    <script type="module">
      import mermaid from 'https://unpkg.com/mermaid@9/dist/mermaid.esm.min.mjs';
      mermaid.initialize({ startOnLoad: true });
    </script>
  </body>
</html>
    
