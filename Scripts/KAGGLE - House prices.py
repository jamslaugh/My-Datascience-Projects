# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 20:24:13 2017

@author: Giacomo
"""
import os
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import Imputer

import random
%matplotlib inline

os.getcwd()

os.chdir('C:\\Users\\Giacomo\\Documenti\\ML Training')
# %%
train = pd.read_csv("C:\\Users\\Giacomo\\Documenti\\ML Training\\KAGGLE\\House Prices\\train.csv",index_col = 'Id')
test = pd.read_csv("C:\\Users\\Giacomo\\Documenti\\ML Training\\KAGGLE\\House Prices\\test.csv",index_col = 'Id')
# %%
train.shape;train.head(); train.info(); train.describe()
train.columns
train.shape;test.head(); test.info(); train.describe()
test.columns

all_data = pd.concat([train,test],join = 'inner',axis = 0)

all_data.shape;all_data.info();all_data.describe();all_data.columns;
all_data.head()

y = train['SalePrice']


# %%
# Analyze sales prices

train['SalePrice'].describe()

# Ok, so SalePrice has an evident Kurtosis and a certain Skewness... Now, let's go further in:
plt.figure()
sns.distplot(train['SalePrice'])

print('Raw data Kurtosis is:\n ' + str(train['SalePrice'].kurt()))
print('Raw data Skewness is:\n ' + str(train['SalePrice'].skew()))
print('Loglinear Kurtosis is:\n '+str(np.log1p(train['SalePrice']).kurt()))
print('Loglinear Skewness is:\n '+str(np.log1p(train['SalePrice']).skew()))

# So, log transformation reduces by a significative amount the asymmetry.
plt.figure()
sns.distplot(np.log1p(train['SalePrice']))
plt.show()
# Oh, wow, it really allows to reduce skewness and kurtosis!
# %%
# Count total NA in dataset:

total = all_data.isnull().sum().sort_values(ascending = False)
percent = (all_data.isnull().sum()/all_data.isnull().count()).sort_values(ascending = False)
null_data = pd.concat([total,percent],keys=['Total','Percent'],axis = 1)

# From this analysis I have decided to eliminate first five elements of cat_null from test and training

rows = percent.index.values

_ = plt.figure()
_ = sns.set()
_ = sns.barplot(rows[percent.values > 0.02],percent.values[percent.values > 0.02])
_ = plt.xticks(rotation = 45,ha='right')
plt.show()

bool_thres = np.logical_and(percent> 0 , percent<= 0.15)

_ = plt.figure()
_ = sns.set()
_ = sns.barplot(rows[bool_thres],percent.values[bool_thres])
_ = plt.xticks(rotation = 45,ha='right')
plt.show()

perc_mean = np.mean(null_data.Percent)

# %%
# Columns to be deleted are the ones with more than 15% missing data: 

wrong_col = np.ndarray.tolist(rows[percent.values > 0.15])

all_data = all_data.drop(wrong_col,axis = 1)
# %%
# Cat vs Nun variables:

train_cat = all_data.select_dtypes(exclude=['int64','float64'])
train_num = all_data.select_dtypes(include=['int64','float64'])
tn_cols = np.ndarray.tolist(train_num.columns.values)

num_null = train_num.isnull().sum().sort_values(ascending = False)
num_percent = (num_null/train_num.isnull().count()).sort_values(ascending = False)
cat_null = train_cat.isnull().sum().sort_values(ascending = False)
cat_percent = (train_cat.isnull().sum()/train_cat.isnull().count()).sort_values(ascending = False)

tc_descr = train_cat.describe()
tc_info = train_cat.info()

# %% NaN removal - quantitative variables

imputer = Imputer(missing_values = 'NaN',strategy='median',axis = 0)
imputer.fit(train_num)
train_num_imputed = imputer.transform(train_num)
train_num_imputed = pd.DataFrame(train_num_imputed)
train_num_imputed.columns = np.ndarray.tolist(train_num.columns.values)
train_num = pd.DataFrame(train_num_imputed)
# %% NaN removal Qualitative Variables
train_cat = pd.get_dummies(train_cat,drop_first = True)
imputer = Imputer(missing_values = 'NaN',strategy='most_frequent',axis = 0)
imputer.fit(train_cat)
train_cat_imputed = imputer.transform(train_cat)
train_cat_imputed = pd.DataFrame(train_cat_imputed)
train_cat_imputed.columns = np.ndarray.tolist(train_cat.columns.values)
train_cat = pd.DataFrame(train_cat_imputed)
# %% NaN check

num_null_1 = train_num.isnull().sum().sort_values(ascending = False)
num_percent_1 = (num_null/train_num.isnull().count()).sort_values(ascending = False)
cat_null_1 = train_cat.isnull().sum().sort_values(ascending = False)
cat_percent_1 = (train_cat.isnull().sum()/train_cat.isnull().count()).sort_values(ascending = False)

# %% 
all_data = pd.concat([train_num,train_cat],axis = 1)
# %% Refreshing NA count
total = all_data.isnull().sum().sort_values(ascending = False)
percent = (all_data.isnull().sum()/all_data.isnull().count()).sort_values(ascending = False)
null_data = pd.concat([total,percent],keys=['Total','Percent'],axis = 1)

# %% Getting Dummy variables
all_data = pd.get_dummies(all_data,drop_first = True)
# %% EDA - 1 In EDA we go through training set.

# EDA can be done by slicing y_train data in classes:

plt.figure()

_ = sns.set()
_ = plt.hist(np.log1p(y), bins = 100, normed = True)
_ = sns.distplot(np.log1p(y), bins = 100)
_ = plt.title('House prices mass function')

plt.show()

# As we increase binning, we have much more outliers. We can choose an average of 100 bins:
plt.figure()
_ = sns.set()
_ = plt.hist(np.log1p(y), bins = 500, normed = True)
_ = sns.distplot(np.log1p(y), bins = 500)
_ = plt.title('House prices mass function')
plt.show()

# 4) Heatmap NOTE: in this case we have no dummy variable over qualitative aspect.

correl_matrix = train.corr()

plt.figure()
_ = plt.subplots(figsize=(12,9))
_ = sns.heatmap(correl_matrix,vmax=0.8,square= True, cmap = 'RdYlGn')
_ = plt.title('Correlation among variables')
_ = plt.tight_layout()
plt.savefig('Correlation Heatmap.png',dpi=900,bbox='tight')
plt.show()

# Alternatively, a very usefull element is given by the following solution: correlation lower triangular

mask = np.zeros_like(correl_matrix, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True

plt.figure()
f,ax = plt.subplots(figsize=(11,9))
cmap = sns.diverging_palette(200,11,as_cmap = True)
sx = sns.heatmap(correl_matrix, mask=mask, cmap=cmap, vmax=.8, center=0,
            square=True, linewidths=.5, cbar_kws={"shrink": .5})
plt.savefig('heatmap revisitedpython.png')
plt.show()

"""
What do we have here? Sale Price has strong correlation with:
    
    - Overall Qual
    - Loot Frontage
    - Lot Area
    - Year Built
    - YearRemodAdd
    - MasVnrArea
    - TotalBsmtSF
    - 1stFlrSF

and so on.
"""
# %% EDA - 2
# We subset for highest elements

k = 10 # TOP TEN!

cols = correl_matrix.nlargest(k,'SalePrice')['SalePrice'].index

cm = np.corrcoef(train[cols].values.T)

# notice, cols is a pandas.core.indexes.base.Index. cols has a .values method that expicits the values contained in cols.
plt.figure()
sns.set(font_scale=1.25)
sm = sns.heatmap(cm, cbar=True, annot=True, square=True, fmt='.2f', annot_kws={'size': 10}, 
                 yticklabels=cols.values, xticklabels=cols.values, cmap = 'RdYlGn')
plt.savefig('Correlation Heatmap zoomed.png',dpi=900,bbox='tight')
plt.show()

# Now, we want to plot scatterplot of relevant element. we have 7X7 scatterplot matrix:
cols1 = list(cols.values)

plt.figure()
sns.set()

sns.pairplot(train[cols1],size = 2.5)
plt.savefig('scatterplot relevant variables python.png')
plt.show()


# Ok, before doing so, we need to gather extra info on the process we are doing.
# We have remaining Missing values and we have to understand wether the missing 
# data is randomic or follows a particular pattern.
# One strategy could be to unite the datasets (train and test), to then perform
# a pipeline approach and a cross validation. The issue, here, however, is that
# we have no output variable on test. 
# Therefore, we can try to impute NaN over splitting train in train and test to
# then perform the imputation with whatever we want.



# 2) check dtypes

X = train_num
train.dtypes.unique()
 