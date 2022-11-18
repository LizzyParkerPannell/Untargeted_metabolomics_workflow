# Elizabeth Parker 17/11/2022
# R code to make workflow diagram for website

# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "DiagrammeR", "RColorBrewer")
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
          
          node[shape = 'cds']
          i [label = '@@18']
          
          node[shape = 'parallelogram']
          j [label = '@@19']
          k [label = '@@19']
          l [label = '@@19']
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          II[label = '@@2', color = '#F46D43', fillcolor = '#F46D43']; # orange
          {rank = same; d; II}
          
          edge[color = 'white']
          b -> d
          d -> e -> j 
          d -> f -> k
          d -> g -> l
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
          j -> m -> p
          k -> n -> q
          l -> o -> r
          
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
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          V[label = '@@5', color = '#E6F598', fillcolor = '#E6F598'] #pale_yellow
          
          edge[color = 'white']
          s -> u
          t -> v
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          IV -> V
          }
          
          subgraph cluster_06{
          bgcolor = '#ABDDA4'
          color = '#ABDDA4'
          
          node[shape = 'parallelogram', style = 'filled', width = 1.5, height = 1, fontname = 'Arial', fillcolor = 'white', color = 'white']
          x [label = '@@30']
          y [label = '@@31']
         {rank = same; x; y}
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          VI[label = '@@6', color = '#ABDDA4', fillcolor = '#ABDDA4'] #pale_green
          
          edge[color = 'white']
          u -> x
          v -> x
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          V -> VI
          x -> y
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
      [30]: paste0('.csv Peak table\\n (samples as rows, \\nm/z as columns)')
      [31]: paste0('.csv meta data\\n (sample, independent \\nvariable 1 …)')

      
      ")
