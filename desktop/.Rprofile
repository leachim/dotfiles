.libPaths(paste0(R.home(), "/library"))
# Things you might want to change
options(papersize="a4") 
options(editor="vim") 
# options(pager="internal")

# R interactive prompt 
# options(prompt="> ")
# options(continue="+ ") 

# to prefer Compiled HTML 
# help options(chmhelp=TRUE) 
# to prefer HTML help 
# options(htmlhelp=TRUE) 

# General options 
options(tab.width = 4) 
options(width = 130)
options(graphics.record=TRUE) 

#.First <- function(){
#    cat("\nWelcome at", date(), "\n") 
#}

#.Last <- function(){ 
#    cat("\nGoodbye at ", date(), "\n")
#}

## Publication quality figures with R

# theme original color values c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")
cbbPalette <- c( "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000")

## theme 
theme_Publication <- function(base_size=24, base_family="Helvetica") {
  library(grid)
  library(ggthemes)
  (theme_foundation(base_size=base_size, base_family=base_family)
  + theme(plot.title = element_text(face = "bold",
                                    size = rel(1.2), hjust = 0.5),
          text = element_text(),
          panel.background = element_rect(colour = NA),
          plot.background = element_rect(colour = NA),
          panel.border = element_rect(colour = NA),
          axis.title = element_text(face = "bold",size = rel(1)),
          axis.title.y = element_text(angle=90,vjust =2),
          axis.title.x = element_text(vjust = -0.2),
          axis.text = element_text(), 
          axis.line = element_line(colour="black"),
          axis.ticks = element_line(),
          panel.grid.major = element_line(colour="#f0f0f0"),
          panel.grid.minor = element_blank(),
          legend.key = element_rect(colour = NA),
          legend.position = "bottom",
          legend.direction = "horizontal",
          legend.key.size= unit(1.0, "cm"),
          legend.margin = unit(0, "cm"),
          legend.title = element_text(face="italic"),
          plot.margin=unit(c(10,5,5,5),"mm"),
          strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
          strip.text = element_text(face="bold")
  ))
  
}

scale_fill_Publication <- function(colourValues=cbbPalette){
  library(scales)
  discrete_scale("fill","Publication",manual_pal(values = cbbPalette), ...)
}

scale_colour_Publication <- function(colourValues=cbbPalette){
  library(scales)
  discrete_scale("colour","Publication",manual_pal(values = colourValues), ...)
}

grid_arrange_shared_legend <- function(...) {
  plots <- list(...)
  g <- ggplotGrob(plots[[1]] + theme(legend.position="bottom"))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  grid.arrange(
    do.call(arrangeGrob, lapply(plots, function(x)
      x + theme(legend.position="none"))),
    legend,
    ncol = 1,
    heights = unit.c(unit(1, "npc") - lheight, lheight))
}


#' ## script for converting .Rmd files to .R scripts.

#' #### Kevin Keenan 2014
#' 
#' This function will read a standard R markdown source file and convert it to 
#' an R script to allow the code to be run using the "source" function.
#' 
#' The function is quite simplisting in that it reads a .Rmd file and adds 
#' comments to non-r code sections, while leaving R code without comments
#' so that the interpreter can run the commands.
#' 
#' 
rmd2rscript <- function(infile){
  # read the file
  flIn <- readLines(infile)
  # identify the start of code blocks
  cdStrt <- which(grepl(flIn, pattern = "```{r*", perl = TRUE))
  # identify the end of code blocks
  cdEnd <- sapply(cdStrt, function(x){
    preidx <- which(grepl(flIn[-(1:x)], pattern = "```", perl = TRUE))[1]
    return(preidx + x)
  })
  # define an expansion function
  # strip code block indacators
  flIn[c(cdStrt, cdEnd)] <- ""
  expFun <- function(strt, End){
    strt <- strt+1
    End <- End-1
    return(strt:End)
  }
  idx <- unlist(mapply(FUN = expFun, strt = cdStrt, End = cdEnd, 
                SIMPLIFY = FALSE))
  # add comments to all lines except code blocks
  comIdx <- 1:length(flIn)
  comIdx <- comIdx[-idx]
  for(i in comIdx){
    flIn[i] <- paste("#' ", flIn[i], sep = "")
  }
  # create an output file
  nm <- strsplit(infile, split = "\\.")[[1]][1]
  flOut <- file(paste(nm, "[rmd2r].R", sep = ""), "w")
  for(i in 1:length(flIn)){
    cat(flIn[i], "\n", file = flOut, sep = "\t")
  }
  close(flOut)
}
