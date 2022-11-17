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
            I[label = '@@1', color = '#D53E4F', fillcolor = '#D53E4F'];
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
          
          node[shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
          II[label = '@@2', color = '#F46D43', fillcolor = '#F46D43'];
          {rank = same; d; II}
          
          edge[color = 'white']
          b -> d
          d -> e 
          d -> f
          d -> g
          d -> h
          
          
          edge[style = 'invisible', arrowhead = 'none', len = 0]
          I -> II
          }
      
      #III[label = '@@3', color = '#FDAE61', shape = 'rectangle', style = 'filled', width = 1.5, fontname = 'Arial', fontcolor = 'white']
    
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
      [13]: 'Which MS?'
      [14]: paste0('MALDI')
      [15]: paste0('DI-ESI-MS')
      [16]: paste0('LC-ESI-MS')
      [17]: paste0('GC-ESI-MS')
      
      ")
