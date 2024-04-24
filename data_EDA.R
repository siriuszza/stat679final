library(VIM)
library(tidyverse)
library(mice)
library(caret)

df = read.csv("./data/metadata/org_metadata.csv")
df[df == -9999] = NA
aggr(df, prop=FALSE, numbers=TRUE)

df_num = df %>% 
  select(u, g, r, i, z, redshift)

imputed_data = mice(df_num, method = "norm.predict", m=1, maxit=10, print=F)
completed_data = complete(imputed_data)
df[, c(4:8, 15)] = completed_data

set.seed(679) # For reproducibility
splitIndex <- createDataPartition(df$class, p = 0.8, list = FALSE)
rnk_test = data.frame(
  class = df$class[-splitIndex],
  rnk = df$rnk[-splitIndex]) %>% 
    mutate(image = paste0("./data/", class, "/", class, "_", rnk, ".jpg"),
           spec = paste0("./data/", class, "_spec",
                         "/", class, "_", rnk, ".jpg"))

write.csv(rnk_test, "./data/rnk_test.csv", row.names = F)

df = df %>%
  mutate(class = case_when(
    class == "STAR" ~ 2,
    class == "GALAXY" ~ 0,
    class == "QSO" ~ 1
  ))


df_loges = df %>% select(u, g, r, i, z,
                         redshift,
                         class, rnk)


trainData <- df_loges[splitIndex, -8]
testData <- df_loges[-splitIndex, -8]

write.csv(df, "./data/metadata/clean_data.csv", row.names = F)
write.csv(trainData, "./data/metadata/train_metadata.csv", row.names = F)
write.csv(testData, "./data/metadata/test_metadata.csv", row.names = F)
