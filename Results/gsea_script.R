library(readxl)
library(ggplot2)
library(gridExtra)
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(WebGestaltR)
library(dplyr)

de_files <- list.files("./DESeq2/", pattern = ".xlsx", full.names = TRUE, recursive=TRUE)
de_files <- lapply(de_files, read_excel)
names(de_files) <- gsub("/.*", "", list.files("./DESeq2/", pattern = ".xlsx", full.names = FALSE, recursive=TRUE))

create_go <- function(df, con = x){
  
  universe <- df %>% pull(Entrez.ID) %>% unique
  x_tss <- subset(df, df$padj < 0.05 & abs(df$Distance.to.TSS) < 1000)
  
  if(nrow(x_tss) > 0) {
  
  x_tss_up <- x_tss %>% filter(log2FoldChange > 0) %>% pull(Entrez.ID) %>% unique
  x_tss_down <- x_tss %>% filter(log2FoldChange < 0) %>% pull(Entrez.ID) %>% unique
  
  dir.create(paste0("./DESeq2/", con, "/Pathway_Enrichment/"), showWarnings = FALSE)
  
  WebGestaltR(enrichMethod = "ORA",
                    organism = "hsapiens",
                    interestGeneType = "genesymbol",
                    referenceGeneType = "genesymbol",
                    enrichDatabase = "geneontology_Biological_Process",
                    interestGene = x_tss_up,
                    referenceGene = universe,
                    projectName = paste0(con, "_go_up"),
                    outputDirectory = paste0("./DESeq2/", con, "/Pathway_Enrichment/")) 

 WebGestaltR(enrichMethod = "ORA",
                   organism = "hsapiens",
                   interestGeneType = "genesymbol",
                   referenceGeneType = "genesymbol",
                   enrichDatabase = "geneontology_Biological_Process",
                   interestGene = x_tss_down,
                   referenceGene = universe,
                   projectName = paste0(con, "_go_down"),
                   outputDirectory = paste0("./DESeq2/", con, "/Pathway_Enrichment/")) 

# Modify command, this one seemed to work on MacOS...
system(paste0("sed -i '' -e '/<header>/,/<\\/header>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_go_down/Report_", con, "_go_down.html"))
system(paste0("sed -i '' -e '/<header>/,/<\\/header>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_go_up/Report_", con, "_go_up.html"))
system(paste0("sed -i '' -e '/<footer/,/<\\/footer>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_go_down/Report_", con, "_go_down.html"))
system(paste0("sed -i '' -e '/<footer/,/<\\/footer>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_go_up/Report_", con, "_go_up.html"))

WebGestaltR(enrichMethod = "ORA",
            organism = "hsapiens",
            interestGeneType = "genesymbol",
            referenceGeneType = "genesymbol",
            enrichDatabase = "pathway_KEGG",
            interestGene = x_tss_up,
            referenceGene = universe,
            projectName = paste0(con, "_kegg_up"),
            outputDirectory = paste0("./DESeq2/", con, "/Pathway_Enrichment/")) 

WebGestaltR(enrichMethod = "ORA",
            organism = "hsapiens",
            interestGeneType = "genesymbol",
            referenceGeneType = "genesymbol",
            enrichDatabase = "pathway_KEGG",
            interestGene = x_tss_down,
            referenceGene = universe,
            projectName = paste0(con, "_kegg_down"),
            outputDirectory = paste0("./DESeq2/", con, "/Pathway_Enrichment/")) 

# Modify command, this one seemed to work on MacOS...
system(paste0("sed -i '' -e '/<header>/,/<\\/header>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_kegg_down/Report_", con, "_kegg_down.html"))
system(paste0("sed -i '' -e '/<header>/,/<\\/header>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_kegg_up/Report_", con, "_kegg_up.html"))
system(paste0("sed -i '' -e '/<footer/,/<\\/footer>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_kegg_down/Report_", con, "_kegg_down.html"))
system(paste0("sed -i '' -e '/<footer/,/<\\/footer>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_kegg_up/Report_", con, "_kegg_up.html"))

  } else {
  
    dir.create(paste0("./DESeq2/", con, "/Pathway_Enrichment/"), showWarnings = FALSE)
    
    x_tss_gsea <- df %>% filter(abs(Distance.to.TSS) < 1000)
    ranks <- data.frame(genes = x_tss_gsea$Entrez.ID,
                        scores = x_tss_gsea$log2FoldChange)
    ranks <- ranks[!duplicated(ranks$genes), ]
    
    WebGestaltR(enrichMethod = "GSEA",
                organism = "hsapiens",
                interestGeneType = "genesymbol",
                enrichDatabase = "pathway_KEGG",
                sigMethod = "top",
                topThr = 20,
                interestGene = ranks,
                referenceGene = universe,
                projectName = paste0(con, "_gsea"),
                outputDirectory = paste0("./DESeq2/", con, "/Pathway_Enrichment"))    
    
    system(paste0("sed -i '' -e '/<header>/,/<\\/header>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_gsea/Report_", con, "_gsea.html"))
    system(paste0("sed -i '' -e '/<footer/,/<\\/footer>/d' ./DESeq2/", con, "/Pathway_Enrichment/Project_", con, "_gsea/Report_", con, "_gsea.html"))
    
}
}

lapply(names(de_files), function(x) create_go(de_files[[x]], x))

