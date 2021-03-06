#####
# Data Description/viz

# Packages
# install.packages("plotly")

# libraries
library(plotly)
#install.packages("tibble")
library(tibble)

# Doctors by state
states = unique(info.all$State)
doc.states = data.frame(states=matrix(0,ncol=1,nrow=length(states)))
rownames(doc.states) = states
for (i in 1:length(states)) {
  doc.states[i,1]=nrow(info.all[info.all$State==states[i],])
}

plot_ly(x=rownames(doc.states),
        y=doc.states$states, type = 'bar') %>%
  layout(title = 'Number of Clinicians by State',
         yaxis = list(title="Number of Clinicians"),xaxis = list(title="State"))

# Types of clinicians

clin_tot <- data.frame(observation= colnames(credmat),
                       value = c(colSums(credmat,na.rm = TRUE)))
clin_tot2 <- clin_tot
clin_tot2[4,] <- clin_tot[5,]
clin_tot2[5,] <- clin_tot[4,]
plot_ly(data=clin_tot2, labels = ~observation, values = ~value, type = 'pie',
        textfont = list(size = 20)) %>%
  layout(title = 'Types of Clinicians',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         legend = list(font = list(size=22)))

plot_ly(x=c("doctor","nurse","other","PA","pharm"),
        y=clin_tot$value, type = 'bar') %>%
  layout(title = 'Number of Clinicians')

# Clinicians that give at least 10 prescriptions of opiates
clin_opiate = cbind(info.all[,5:9],info.all$Opioid.Prescriber,info.all$opiate)
colnames(clin_opiate) = c("doctor","nurse","other","PA","pharm","Opioid.Prescriber","opiate")
clin_opiate=clin_opiate[clin_opiate$Opioid.Prescriber==1,]

clin_tot_opiate <- data.frame(observation= colnames(credmat),
                              value = c(colSums(clin_opiate[,1:5],na.rm = TRUE)))
plot_ly(data=clin_tot_opiate, labels = ~observation, values = ~value, type = 'pie',
        textfont = list(size = 20)) %>%
  layout(title = 'Types of Clinicians With > 10 Opioid Prescriptions',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         legend = list(font = list(size=22)))

clin_tot_opiate2 <- clin_tot_opiate[1:2,]
clin_tot_opiate2[3,] <- clin_tot_opiate[4,]
plot_ly(data=clin_tot_opiate2, labels = ~observation, values = ~value, type = 'pie',textinfo='value',
        textfont = list(size = 20)) %>%
  layout(title = 'Types of Clinicians With > 10 Opioid Prescriptions',titlefont = list(size = 18),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         legend = list(font = list(size=22)))

# Clinicians that give 0 prescriptions of opiates
clin_opiate0 = cbind(info.all[,5:9],info.all$Opioid.Prescriber,info.all$opiate)
colnames(clin_opiate0) = c("doctor","nurse","other","PA","pharm","Opioid.Prescriber","opiate")
clin_opiate0=clin_opiate[clin_opiate0$opiate==0,]

clin_tot_opiate0 <- data.frame(observation= colnames(credmat),
                              value = c(colSums(clin_opiate0[,1:5],na.rm = TRUE)))
plot_ly(data=clin_tot_opiate0, labels = ~observation, values = ~value, type = 'pie',
        textfont = list(size = 20)) %>%
  layout(title = 'Types of Clinicians With 0 Opioid Prescriptions',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         legend = list(font = list(size=22)))

clin_tot_opiate0_2 <- clin_tot_opiate0[1:2,]
clin_tot_opiate0_2[3,] <- clin_tot_opiate0[4,]
plot_ly(data=clin_tot_opiate0_2, labels = ~observation, values = ~value, type = 'pie',textinfo='value',
        textfont = list(size = 20)) %>%
  layout(title = 'Types of Clinicians With 0 Opioid Prescriptions',titlefont = list(size = 18),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         legend = list(font = list(size=22)))



# Average Prescriptions Given out by each type of Clinician
clin_opiate2 = cbind(info.all[,5:9],info.all$opiate)
colnames(clin_opiate2) = c("doctor","nurse","other","PA","pharm","opiate")
clin_opiate_morethan10 = clin_opiate2[clin_opiate2$opiate>10,]

clin_tot_opiate_mean=c(mean(clin_opiate2$opiate[clin_opiate2[1]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[2]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[3]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[4]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[5]==1],na.rm=TRUE))

clin_tot_opiate_mean_morethan10=c(mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[1]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[2]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[3]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[4]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[5]==1],na.rm=TRUE))

clin_tot_opiate_median=c(median(clin_opiate2$opiate[clin_opiate2[1]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[2]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[3]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[4]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[5]==1],na.rm=TRUE))

clin_tot_opiate_median_morethan10=c(median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[1]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[2]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[3]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[4]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[5]==1],na.rm=TRUE))


plot_ly(x=c("Doctor","Nurse","other","PA","pharm"),
             y=clin_tot_opiate_mean, type = 'bar') %>%
  layout(title = 'Mean Opiate Prescriptions',titlefont = list(size = 18),
         yaxis = list(title="Mean",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","other","PA","pharm"),
             y=clin_tot_opiate_mean_morethan10, type = 'bar') %>%
  layout(title = 'Mean Opiate Prescriptions Where Opiate RX>10',titlefont = list(size = 18),
         yaxis = list(title="Mean",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","other","PA","pharm"),
             y=clin_tot_opiate_median, type = 'bar') %>%
  layout(title = 'Median Opiate Prescriptions',titlefont = list(size = 18),
         yaxis = list(title="Median",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","other","PA","pharm"),
             y=clin_tot_opiate_median_morethan10, type = 'bar') %>%
  layout(title = 'Median Opiate Prescriptions Where Opiate RX>10',titlefont = list(size = 18),
         yaxis = list(title="Median",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

# Take out the pharm and other types of clinicians
clin_tot_opiate_mean_3clin=c(mean(clin_opiate2$opiate[clin_opiate2[1]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[2]==1],na.rm=TRUE),
                       mean(clin_opiate2$opiate[clin_opiate2[4]==1],na.rm=TRUE))

clin_tot_opiate_mean_morethan10_3clin=c(mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[1]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[2]==1],na.rm=TRUE),
                                  mean(clin_opiate_morethan10$opiate[clin_opiate_morethan10[4]==1],na.rm=TRUE))

clin_tot_opiate_median_3clin=c(median(clin_opiate2$opiate[clin_opiate2[1]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[2]==1],na.rm=TRUE),
                         median(clin_opiate2$opiate[clin_opiate2[4]==1],na.rm=TRUE))

clin_tot_opiate_median_morethan10_3clin=c(median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[1]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[2]==1],na.rm=TRUE),
                                    median(clin_opiate_morethan10$opiate[clin_opiate_morethan10[4]==1],na.rm=TRUE))

plot_ly(x=c("Doctor","Nurse","PA"),
        y=clin_tot_opiate_mean_3clin, type = 'bar') %>%
  layout(title = 'Mean Opiate Prescriptions',titlefont = list(size = 18),
         yaxis = list(title="Mean",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","PA"),
        y=clin_tot_opiate_mean_morethan10_3clin, type = 'bar') %>%
  layout(title = 'Mean Opiate Prescriptions Where Opiate RX>10',titlefont = list(size = 18),
         yaxis = list(title="Mean",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","PA"),
        y=clin_tot_opiate_median_3clin, type = 'bar') %>%
  layout(title = 'Median Opiate Prescriptions',titlefont = list(size = 18),
         yaxis = list(title="Median",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

plot_ly(x=c("Doctor","Nurse","PA"),
        y=clin_tot_opiate_median_morethan10_3clin, type = 'bar') %>%
  layout(title = 'Median Opiate Prescriptions Where Opiate RX>10',titlefont = list(size = 18),
         yaxis = list(title="Median",tickfont = list(size = 20),titlefont = list(size = 20)),
         xaxis = list(tickfont = list(size = 20)))

#p <- subplot(p1, p2, p3, p4,nrows = 2)
#p

# Histogram

plot_ly(x=clin_opiate$opiate[clin_opiate$opiate>1 & clin_opiate$opiate<5000], 
        type = 'histogram',nbinsx=20) %>%
  layout(title = 'Histogram of Clinician Counts Where Opiates Prescribed 1<RX<5000',
         yaxis = list(type='log',title="Number of Prescriptions (log)",tickfont = list(size = 20),titlefont = list(size = 20)), 
         xaxis = list(title="Clinicians (binned)",tickfont = list(size = 20),titlefont = list(size = 20)))

plot_ly(x=clin_opiate$opiate[clin_opiate$opiate>1 & clin_opiate$opiate<300], 
        type = 'histogram',nbinsx=20) %>%
  layout(title = 'Histogram of Clinician Counts Where Opiates Prescribed 1<RX<500',
         yaxis = list(type='log',title="Number of Prescriptions (log)",tickfont = list(size = 20),titlefont = list(size = 20)), 
         xaxis = list(title="Clinicians (binned)",tickfont = list(size = 20),titlefont = list(size = 20)))

# Other Statistics
colMax <- function(data) sapply(data,max,na.rm = TRUE)


# Clinicians for top # of prescriptions
clin_opiate = cbind(info.all.back[,1:11],info.all$Opioid.Prescriber,info.all$opiate)
colnames(clin_opiate) = c("State","NPI","Gender.F","Gender.M","Credentials","doctor","nurse","other","PA","pharm","Specialty","Opioid.Prescriber","opiate")
clin_opiate=clin_opiate[clin_opiate$Opioid.Prescriber==1,]

top50 = tbl_df(clin_opiate) %>% top_n(100,opiate)
unique(top50$Specialty)

# top20 = tbl_df(clin_opiate) %>% top_n(20,opiate)
# top20 = top20[order(top20$opiate,decreasing = TRUE),]
# top20[,12]=NULL
# top20[,6:10]=NULL
# top20[,2:4]=NULL
# plot.new()
# grid.table(top20)



# Top deathrate for states
clin_opiate = cbind(info.all.back[,1:11],info.all$Opioid.Prescriber,info.all$opiate)
colnames(clin_opiate) = c("State","NPI","Gender.F","Gender.M","Credentials","doctor","nurse","other","PA","pharm","Specialty","Opioid.Prescriber","opiate")
clin_opiate=clin_opiate[clin_opiate$Opioid.Prescriber==1,]

top5state = info.all.back[info.all.back$deathrate %in% sort(unique(info.all.back$deathrate),decreasing =TRUE)[1:5],]
unique(top5state$State)

# Rank state data
OD.st = OD.state


for (i in 1:nrow(OD.state)){
  currow = info.all.back[as.character(info.all.back$State)==as.character(OD.st$State[i]),]
  OD.st$medOpiate[i] = round(median(currow$opiate))
  OD.st$avgOpiate[i] = round(sum(currow$opiate)/ nrow(currow),2)
  # OD.st$deathrate[i] = as.numeric(gsub(",","",OD.st$Deaths[i],fixed=TRUE)) / as.numeric(gsub(",","",OD.st$Population[i],fixed=TRUE))
  OD.st$deathper100k[i] = round(as.numeric(gsub(",","",OD.st$Deaths[i],fixed=TRUE)) / (as.numeric(gsub(",","",OD.st$Population[i])) / 100000),2)
}

OD.st$rank.avgOpiate = rank(-OD.st$avgOpiate)
OD.st$rank.medOpiate = rank(-OD.st$medOpiate)
OD.st$rank.deaths = rank(-OD.st$deathper100k)

plot.new()
g1 = tableGrob(OD.st[order(OD.st$rank.avgOpiate)[1:5],],rows=NULL)
g2 = tableGrob(OD.st[order(OD.st$rank.medOpiate)[1:5],],rows=NULL)
g3 = tableGrob(OD.st[order(OD.st$rank.deaths)[1:5],],rows=NULL)

grid.arrange(g1,g2,g3, nrow=3, top="States Ranked by Avg/Med Opiates Prescribed(Upper/Mid) and Deaths/100K(Lower)")
plot.new()
grid.table(OD.st[order(OD.st$rank.deaths)[1:5],])

OD.st[order(OD.st$rank.avgOpiate)[1:5],]
OD.st[order(OD.st$rank.deathrate)[1:5],]

plot_ly(x= OD.st$deathper100k, 
        type = 'histogram',nbinsx=15) %>%
  layout(title = 'Histogram of Death Rates in All States',
         yaxis = list(title="Number of States",tickfont = list(size = 20),titlefont = list(size = 16)), 
         xaxis = list(title="Number of Deaths per 100,000 People",tickfont = list(size = 20),titlefont = list(size = 16)))


