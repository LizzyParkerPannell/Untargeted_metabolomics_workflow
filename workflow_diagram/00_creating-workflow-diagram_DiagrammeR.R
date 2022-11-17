# Elizabeth Parker 17/11/2022
# R code to make workflow diagram for website

# Load required packages
packages_to_load <- c("tidyr", "tibble", "dplyr", "readr", "stringr", "DiagrammeR")
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


grViz("
      digraph flow{
      
      #arrangement attributes
      splines = ortho
      overlap = orthoxy
      rankdir = 'TB'
      
      subgraph stage_01{
      
      cluster=TRUE
      #node [shape = 'rectangle', style = 'filled', width = 7, fontname = 'Arial]
      #I [label = '@@10'];
      
        subgraph metabolite_extraction{
        
        node [shape = 'diamond', style = 'filled', width = 1.5, height = 1, fontname = 'Arial']
        a [label = '@@1']; 
        {rank = min; a}
      
        node[shape = 'invtrapezium', style = 'filled', width = 1.5 height = 1, fontname = 'Arial']
        b [label = '@@2']; 
        c [label = '@@3'];
        {rank = max; b}
        
        # Connect nodes with edges and labels
        a -> b [label = 'Plants', fontname = 'Arial']
        a -> c [label = 'Bacteria', fontname = 'Arial']
        c -> b
      }}

      subgraph stage_02{
      
      cluster=TRUE
      
        subgraph mass_spec{
        
        node [shape = 'diamond', style = 'filled', width = 1.5, height = 1, fontname = 'Arial']
        d [label = '@@4'];
      
        node[shape = 'rectangle', style = 'filled', width = 1.5 height = 1, fontname = 'Arial']
        e [label = '@@5']; 
        f [label = '@@6'];
        g [label = '@@7'];
        h [label = '@@8'];
        {rank = same; e; f; g; h}
        
        node[shape = 'parallelogram', style = 'filled', width = 1.5 height = 1, fontname = 'Arial']
        i [label = '@@9'];
      
        # Connect nodes with edges and labels
        b -> d
        d -> e
        d -> f
        d -> g
        d -> h
        e -> i
        f -> i
        g -> i
        h -> i
        }}
      }
        
      [1]: 'Bacteria or plants' 
      [2]: paste0('Quenching,\\n extraction &\\n phase separation') 
      [3]: paste0('Growth &\\n isiolation of cells')  
      [4]: 'Which MS?'
      [5]: paste0('Matrix Assisted Laser\\n Desorption Ionisation\\n (MALDI-ToF)')
      [6]: paste0('Direct Injection\\n Mass Spectrometry\\n (DI-ESI-MS)')
      [7]: paste0('Liquid Chromatography\\n Mass Spectrometry\\n (LC-ESI-MS)')
      [8]: paste0('Gas Chromatography\\n Mass Spectrometry\\n (GC-ESI-MS)')
      [9]: paste0('.RAW files\\n from MassLynx')
      
      #[10]: 'Stage 01 - Metabolite Extraction'
      
  
")

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
        
           # Connect nodes with edges and labels
           edge[color = 'white']
           a -> b [label = 'Plants', fontname = 'Arial', fontcolor = 'white']
           a -> c [label = 'Bacteria', fontname = 'Arial', fontcolor = 'white']
           c -> b
            }
          
          subgraph cluster_02{
          bgcolor = '#F46D43'
          color = '#F46D43'
          }
      
      node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
      I[label = '@@1', color = '#D53E4F', fillcolor = '#D53E4F'];
      II[label = '@@2', color = '#F46D43'];
      III[label = '@@3', color = '#FDAE61']
      
      edge[style = 'invisible', arrowhead = 'none', len = 0]
      I -> II -> III
      
      #aligning stage titles with clusters
      
      }}
      
      [1]: 'Stage 1 Metabolite Extraction'
      [2]: 'Stage 2 Mass Spectrometry'
      [3]: 'Stage 3 Data conversion to open format'
      [4]: 'Stage 4 Data Pre-processing'
      [5]: 'Stage 5 Extract & format peak table & metadata'
      [6]: 'Stage 6 Multivariate Analysis'
      [7]: 'Stage 7 Putative Metabolite Identification'
      [8]: 'Stage 8 Data archiving & reporting'
      [9]:
      [10]: 'Bacteria or plants' 
      [11]: paste0('Quenching,\\n extraction &\\n phase separation') 
      [12]: paste0('Growth &\\n isolation of cells')  
      
      ")
