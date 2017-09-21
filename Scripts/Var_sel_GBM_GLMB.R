#################
library(caret)

names(getModelInfo())

library(RCurl) # download https data

urlfile <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/GISETTE/gisette_train.data'
x <- getURL(urlfile, ssl.verifypeer = FALSE)
gisetteRaw <- read.table(textConnection(x), sep = '', header= FALSE, stringsAsFactors = FALSE)

urlfile <- "https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/GISETTE/gisette_train.labels"
x <- getURL(urlfile, ssl.verifypeer = FALSE)
g_labels <- read.table(textConnection(x), sep = '', header = FALSE, stringsAsFactors = FALSE)
# build data set
gisette_df <- cbind(as.data.frame(sapply(gisetteRaw, as.numeric)), cluster=g_labels$V1)

set.seed(1234)

# notice: we are going to split our data in two ways: one 50 - 50 between training-testing and validation, respectively,
# to, then, split 50 - 50 between training and testing of first halved dataset. This phase no column reduction has brought in.
# With validation:
split <- sample(nrow(gisette_df),floor(0.5*nrow(gisette_df)))
gisette_df_train_test <- gisette_df[split,]

# Validation dataset is just for scoring:

gisette_df_validate <- gisette_df[-split,]

# Train and test:

set.seed(1234)
split <- sample(nrow(gisette_df_train_test),floor(0.5*nrow(gisette_df_train_test)))
traindf <- gisette_df_train_test[split,]
testdf <- gisette_df_train_test[-split,]

# caret requires a factor of non-numeric value
# traindf$cluster <- ifelse(traindf$cluster == 1, "yes", "no")
traindf$cluster <- as.factor(traindf$cluster )

fitControl <- trainControl(method='cv', number=3, returnResamp='none', verboseIter= FALSE,
                           summaryFunction = twoClassSummary, classProbs = TRUE)
gbm_model <- train(cluster~., data=traindf, trControl=fitControl, method="gbm",
                   metric='roc')

# The above method will tell the ideal variables to be taken.

print(gbm_model)

predictions <- predict(object = gbm_model, testdf[,setdiff(names(testdf),'cluster')],type = 'raw')

head(predictions)

print(postResample(pred = predictions, obs = as.factor(testdf$cluster)))
