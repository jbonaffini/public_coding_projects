#just need info.all

info.clustering <- info.all[,c(2:length(info.all))]
for (i in c(1:length(colnames(info.clustering)))) {
  #print(i)
  #print(typeof(info.all[,i][2]))
  #print(is.numeric(info.all[,i][2]))
  #print(info.all[,i][2])
  if (typeof(info.clustering[,i][2]) != "double") {
    info.clustering[,i] = as.numeric(info.clustering[,i])
    info.clustering[,i] <- sapply(info.clustering[, i], as.numeric)
    print("Done")
  }
}


info.clustering
spam.kmeans <- kmeans(info.clustering, centers = 5, nstart = 20, trace = TRUE)
spam.kmeans$centers
ggplot(info.clustering, aes(Population, deathrate)) +
  geom_point(col = c("blue", "red", "green", "orange", "purple")[spam.kmeans$cluster])

spam.kmeans$cluster
spam.kmeans$totss
sum(spam.kmeans$withinss)
vector <- rep(NA, 50)
for (i in c(1:50)) {
  spam.kmeans_sim <- kmeans(info.clustering, centers = i, nstart = 20, trace = TRUE)
  vector[i] = sum(spam.kmeans_sim$withinss)
}
scale(vector)
mse_kmeans = as.data.frame(cbind(as.numeric(c(1:50)), as.numeric(scale(vector))))
colnames(mse_kmeans) <- c("x", "y")
ggplot((mse_kmeans), aes_string("x", "y")) + 
  geom_point() +
  scale_x_continuous(name="Number of clusters", limits=c(1, 50)) +
  ylab("MSE") +
  ggtitle("MSE vs Number of Clusters") +
  theme_bw()