library(readstata13)
library(ggplot2)
library(Matrix)
library(data.table)
library(xtable)
library(grid)
library(cowplot)
library(gridExtra)
library(foreign)
library(dplyr)
library(tidyr)

setwd("/Users/Vaishnavi/Dropbox/Bihar RCT All Data/Updated Data/JDE_Relief from Usury_Replication/")
Village <- read.dta13("./Data/Vill_Lender_JDE.dta")

## Interest Rates - Village level
Village.graph <- ggplot(Village, aes(x = Village$informal_rate, fill = as.factor(Village$status))) + 
                 geom_histogram(aes(y = ..density..), position="dodge") +
                 labs(title = "Availability of informal loans at follow-up",
                      x="Monthly Interest Rate", y="Density",
                      fill="Treatment Status") + 
                 scale_fill_manual(name = "Treatment Status", values = c("#99CCFF", "#003366"), 
                                   labels=c("Control", "Treatment")) +
                 theme_bw() + theme(legend.position="bottom") +
                 scale_x_continuous(breaks=c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
                                    limits=c(0,10.5))

pdf("./Output/Loans.pdf")
Village.graph
dev.off()



