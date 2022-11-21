# Elizabeth Parker 17/11/2022
# R code to make workflow diagram for website

# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "DiagrammeR", "RColorBrewer", "rsvg", "DiagrammeRsvg")
lapply(packages_to_load, require, character.only = TRUE)  

# Don't forget to cite these packages in your thesis/ manuscript (this code will automatically make a table of text citations for you)
cite_packages <- tibble(Package = "1", Citation = "1")
for (i in 1:length(packages_to_load)){
  j <- packages_to_load[i]
  
  k <- citation(j)$textVersion
  
  cite_packages[i, 1] <- j
  cite_packages[i, 2] <- k
  
}
cite_packages

red <- brewer.pal(8, 'Spectral')[1]
orange <- brewer.pal(8, 'Spectral')[2]
pale_orange <- brewer.pal(8, 'Spectral')[3]
yellow <- brewer.pal(8, 'Spectral')[4]
pale_yellow <- brewer.pal(8, 'Spectral')[5]
pale_green <- brewer.pal(8, 'Spectral')[6]
green <- brewer.pal(8, 'Spectral')[7]
blue <- brewer.pal(8, 'Spectral')[8]

grViz("
      digraph flow{
      
      #arrangement attributes
      splines = ortho
      overlap = orthoxy
      rankdir = 'TB'
      
      subgraph stages{
            
            subgraph cluster_01{
            bgcolor = '#D53E4F'
            color = '#D53E4F'
            
            node [shape = 'diamond', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
            a [label = '@@10']; 
            {rank = min; a}
      
            node[shape = 'invtrapezium', style = 'filled']
            b [label = '@@11']; 
            c [label = '@@12'];
            {rank = max; b}
            
            node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
            I[label = '@@1', color = '#D53E4F', fillcolor = '#D53E4F']; #red
            {rank = same; a ; I}

        
           # Connect nodes with edges and labels
           edge[color = 'white']
           a -> b [label = 'Plants', fontname = 'Arial', fontcolor = 'white']
           a -> c [label = 'Bacteria', fontname = 'Arial', fontcolor = 'white']
           c -> b
            }
          
          subgraph cluster_02{
          bgcolor = '#F46D43'
          color = '#F46D43'
          
          node [shape = 'diamond', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          d [label = '@@13'];
          {rank = min; d}
          
          node[shape = 'rectangle']
          e [label = '@@14']
          f [label = '@@15']
          g [label = '@@16']
          h [label = '@@17']
          
          node[shape = 'parallelogram']
          j [label = '@@19']
          
          node[shape = 'oval', style = 'filled'] # would be best if this was cds symbol but having issues with that
          i [label = '@@18']
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          II[label = '@@2', color = '#F46D43', fillcolor = '#F46D43']; # orange
          {rank = same; d; II}
          
          edge[color = 'white']
          b -> d
          d -> e -> j 
          d -> f -> j 
          d -> g -> j 
          d -> h -> i
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          I -> II
          }
          
          subgraph cluster_03{
          bgcolor = '#FDAE61'
          color = '#FDAE61'
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          m [label = '@@20']
          n [label = '@@21']
          o [label = '@@22']
          
          node[shape = 'parallelogram']
          p [label = '@@23']
          q [label = '@@24']
          r [label = '@@25']
      
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          III[label = '@@3', color = '#FDAE61', fillcolor = '#FDAE61'] #pale orange
          
          edge[color = 'white']
          j -> m -> p[label = 'MALDI', fontname = 'Arial', fontcolor = 'white']
          j -> n -> q[label = 'DI-ESI-MS', fontname = 'Arial', fontcolor = 'white'] 
          j -> o -> r[label = 'LC-ESI-MS', fontname = 'Arial', fontcolor = 'white']
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          II -> III
          
          }
          
          subgraph cluster_04{
          bgcolor = '#FEE08B'
          color = '#FEE08B'
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          s [label = '@@26']
          t [label = '@@27']
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          IV[label = '@@4', color = '#FEE08B', fillcolor = '#FEE08B'] #yellow
          
          edge[color = 'white']
          p -> s
          q -> s
          r -> t
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          III -> IV
          }
          
          subgraph cluster_05{
          bgcolor = '#E6F598'
          color = '#E6F598'
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          u [label = '@@28']
          v [label = '@@29']
         
          node[shape = 'parallelogram', style = 'filled', width = 2, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          x [label = '@@30']
          y [label = '@@31']
         {rank = same; x; y}
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          V[label = '@@5', color = '#E6F598', fillcolor = '#E6F598'] #pale_yellow
          
          edge[color = 'white']
          s -> u -> x
          t -> v -> x
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          IV -> V
          x -> y
          
          }
          
          subgraph cluster_06{
          bgcolor = '#ABDDA4'
          color = '#ABDDA4'
          
          node [shape = 'diamond', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          z [label = '@@32'];
          {rank = min; z}
          
            subgraph cluster_multivariate_analysis{
            bgcolor = '#ABDDA4'
            color = 'white'
            
            node [shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
            a1 [label = '@@33']
            a2 [label = '@@34']
            a3 [label = '@@35']
            a4 [label = '@@36']
            
            node [shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fontcolor = 'white', fillcolor = '#ABDDA4', color = 'white']
            b1 [label = '@@39'];
            b2 [label = '@@40'];
            b3 [label = '@@41'];
          {rank = same; b1; b2; b3}
            
            }
            
          node [shape = 'parallelogram', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          a5 [label = '@@37']
          
          node [shape = 'cds', style = 'filled']
          a6 [label = '@@38']
          {rank = same; a5; a6}
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          VI[label = '@@6', color = '#ABDDA4', fillcolor = '#ABDDA4'] #pale_green
          note1 [label = '@@42', color ='white', fillcolor = '#ABDDA4']
          
          edge[color = 'white']
          x -> z
          a1 -> a2 -> a3 -> a4 -> a5
          a3 -> a6
          a4 -> a6
          z -> b1 [label = 'Open source, \\nlocal, \\nversion control', fontname = 'Arial', fontcolor = 'white']
          z -> b2 [label = 'Open source, \\nonline, \\nguided \\nsense checks', fontname = 'Arial', fontcolor = 'white']
          z -> b3 [label = 'Proprietary, \\npoint & click', fontname = 'Arial', fontcolor = 'white']
          b1 -> b2 [label = 'see note *', fontname = 'Arial', fontcolor = 'white']
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          z -> a1
          b1 -> a1
          V -> VI
          
          }
          
          subgraph cluster_07{
          bgcolor = '#66C2A5'
          color = '#66C2A5'
          
          node [shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          c1 [label = '@@43']
                    
          node [shape = 'parallelogram']
          c2 [label = '@@44']
          
          node [shape = 'cds', style = 'filled']
          c3 [label = '@@45']
          c4 [label = '@@46']
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          VII[label = '@@7', color = '#66C2A5', fillcolor = '#66C2A5'] #green
          
          edge[color = 'white']
          a5 -> c1 -> c2 -> c3
          c2 -> c4
          
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          VI -> VII
          }
          
          subgraph cluster_08{
          bgcolor = '#3288BD'
          color = '#3288BD'
          
          node [shape = 'hexagon', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          d1 [label = '@@47']
          
          node [shape = 'rectangle']
          d2 [label = '@@48']
          
          node [shape = 'triangle']
          d3 [label = '@@49']
          
          node [shape = 'rectangle', style = 'filled', width = 1.5, height = 1, fontname = 'Arial']
          VIII [label = '@@8', fillcolor = '#3288BD', color = '#3288BD', fontcolor = 'white']
          
          edge[color = 'gray70']
          j -> d1
          c2 -> d1
          y -> d1
          
          edge[color = 'white']
          d1 -> d2 -> d3
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          VII -> VIII
          
          }
          
      }}
      
      [1]: 'Stage 1 Metabolite Extraction'
      [2]: 'Stage 2 Mass Spectrometry'
      [3]: 'Stage 3 Data conversion \\nto open format'
      [4]: 'Stage 4 Data Pre-processing'
      [5]: 'Stage 5 Extract & format \\npeak table & metadata'
      [6]: 'Stage 6 Multivariate Analysis'
      [7]: 'Stage 7 Putative Metabolite \\nIdentification'
      [8]: 'Stage 8 Data archiving \\n& reporting'
      [9]:
      [10]: 'Bacteria or plants' 
      [11]: paste0('Quenching,\\n extraction &\\n phase separation') 
      [12]: paste0('Growth &\\n isolation of cells') 
      [13]: 'Which MS?'
      [14]: paste0('MALDI')
      [15]: paste0('DI-ESI-MS')
      [16]: paste0('LC-ESI-MS')
      [17]: paste0('GC-ESI-MS')
      [18]: paste0('GCMS \\nStandardized workflow')
      [19]: paste0('.RAW files\\n from MassLynx')
      [20]: paste0('Convert data\\n Proteowizard  MSConvert\\n * scanEvent\\n * polarity')
      [21]: paste0('Convert & compress data\\n Proteowizard > MSConvert\\n * Scan range\\n * scanEvent\\n * polarity')
      [22]: paste0('Convert & compress data\\n Proteowizard > MSConvert\\n * peakPicking\\n * scanEvent\\n * polarity')
      [23]: paste0('.mzML\\n open format\\n (profile)')
      [24]: paste0('.mzML\\n open format\\n (profile,\\nselected scans)')
      [25]: paste0('.mzML\\n open format\\n (centroid)')
      [26]: paste0(c('MassUp or R to run\\n MALDIquant\\n (baseline correction, normalization, alignment, peak detection)'))
      [27]: paste0('XCMSonline or R to run\\n XCMS\\n (Peak picking, RT correction, alignment, grouping)')
      [28]: paste0('Download each processed sample\\n spectra from MassUp as .csv \\n& tidy in R')
      [29]: paste0('Download results folder \\n& tidy in R')
      [30]: paste0('.csv Peak table\\n (samples as rows, m/z as columns)')
      [31]: paste0('.csv meta data\\n (sample, independent variable 1 …)')
      [32]: paste0('Open source, \\nonline, proprietary \\nand/ or local')
      [33]: paste0('Load data & metadata')
      [34]: paste0('Scaling & normalization')
      [35]: paste0('Exploratory analysis (PCA, PERMANOVA \\n& interpretation')
      [36]: paste0('Directed analysis (OPLS-DA & detailed statistics) \\n& interpretation')
      [37]: paste0('Features of interest \\n(m/z or m/z with retention time)')
      [38]: paste0('Graphs & stats \\nfor reporting')
      [39]: paste0('R and RStudio')
      [40]: paste0('Metaboanalyst')
      [41]: paste0('Proprietary multivariate \\nanalysis software \\n(e.g. SIMCA by Umetrics)')
      [42]: paste0('* Metaboanalyst is R based. \\nClick the button in top left \\nhand corner of the web UI to \\naccess the R script')
      [43]: paste0('Use detected masses of \\ninterest to search databases/ repositories\\n and literature')
      [44]: paste0('Putative identities of metabolites\\n responsible for differences between classes')
      [45]: paste0('Further MS to confirm IDs \\n(targeted, tandem or NMR)')
      [46]: paste0('Pathway analysis \\n enrichment analysis')
      [47]: paste0('Prepare data for\\n submission to repository')
      [48]: paste0('Submit data to MetaboLights')
      [49]: paste0('Remember to \\ncite tools used!')

      
      ") %>%
  export_svg %>% charToRaw %>% rsvg_png("workflow_diagram/workflow_diagram.png")
