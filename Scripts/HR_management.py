# -*- coding: utf-8 -*-
"""
Created on Thu Nov 30 10:30:21 2017

@author: Giacomo
"""

import os
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import Imputer
from sklearn.preprocessing import StandardScaler as ss
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.multiclass import OneVsRestClassifier
from sklearn.model_selection import train_test_split
import random
# %matplotlib inline

os.getcwd()

os.chdir('C:\\Users\\Giacomo\\Documenti\\ML Training')
# %%
data = pd.read_csv("C:\\Users\\Giacomo\\Documenti\\ML Training\\UCI.EDU.DATASETS\\HR data\\HR_comma_sep.csv")
data.head()
data.info()
data.dtypes.value_counts()
data.describe()
# %% Unique variables:

def unique_vals(data):
    cols = np.ndarray.tolist(data.columns.values)
    x = []
    for i in range(len(cols)):
        x.append(data.iloc[:,i].unique())
    z = dict(zip(cols,x))
    return(z)
unique = unique_vals(data)

# %% Categorical Encoding:
def categorize_variables(data):
    categorize_eng = lambda x: x.astype('category')
    cat_var = np.ndarray.tolist(data.select_dtypes(include=['object']).columns.values)
    if len(cat_var) >0:
        x = data[cat_var].apply(categorize_eng,axis=0)
        return x, cat_var
    else:
        print('data has no object variable to categorize')
        
data_cat, cat_var = categorize_variables(data)

data[cat_var] = data_cat


# %% Correlation Matrix

corrmat = data.corr()
# %% EDA
k=100  
sns.set()
plt.figure()  
ax = plt.hist(data.average_montly_hours,bins=k,normed=True)
plt.show()

sns.set()
plt.figure()
data.boxplot('average_montly_hours',by='salary')
plt.show()
# Correlation heatmap among features
sns.set()
plt.figure()
_ = sns.heatmap(corrmat)
plt.show()

sns.set()
plt.figure()
_ = sns.heatmap(corrmat.drop('number_project',axis = 0).drop('number_project',axis=1))
plt.show()

sns.set()
plt.figure()
_ = sns.violinplot(x='salary',y = 'average_montly_hours',data=data)
_ = sns.swarmplot(x='salary',y = 'average_montly_hours',data=data)
plt.show()

sns.set()
plt.figure()
_ = sns.pairplot(data,size = 2.5)
plt.show()

# %% categorical Variables show:

num_unique = data[cat_var].apply(pd.Series.nunique)
num_unique.plot(kind='bar')
plt.xlabel('Labels')
plt.ylabel('Number of unique labels')
plt.show()

sales_dist = data.groupby(['sales'])['sales'].count()
sales_joint_salary = data.groupby(['sales','salary']).count()
salary_dist = data.groupby(['salary'])['salary'].count()
# plotting for sales_dist
# %% Graphing:
plt.figure()
sns.set()
_ = sales_dist.plot(kind='bar')
plt.show()

plt.figure()
sns.set()
_ = salary_dist.plot(kind='bar')
plt.show()

plt.figure()
sns.set()
_ = sales_joint_salary.plot(kind='bar')
plt.show()

# We have both skewed and high variance data!
# %% compute log loss:

def compute_log_loss(predicted, actual, eps=1e-14):
 """ Computes the logarithmic loss between predicted and
 actual when these are 1D arrays.

 :param predicted: The predicted probabilities as floats between 0-1
 :param actual: The actual binary labels. Either 0 or 1.
 :param eps (optional): log(0) is inf, so we need to offset our
 predicted values slightly by eps from 0 or 1.
 """
 predicted = np.clip(predicted, eps, 1 - eps)
 loss = -1 * np.mean(actual * np.log(predicted) + (1 - actual)* np.log(1 - predicted))

 return loss

# %% ML modeling stratified shuffle split (if tgt is single) or multilabel_train_test_split (multicolumn tgt):
runfile('C:/Users/Giacomo/Documents/ML training/multilabel_train_test_split.py', wdir='C:/Users/Giacomo/Documents/ML training')

# %% ML building:

X =data.iloc[:,:8]

y = data.iloc[:,9]
# %% A) stratified train test split
X_train,X_test,y_train,y_test = train_test_split(X,y,stratify = y,random_state=42)

clf = OneVsRestClassifier(LogisticRegression())

# %% Scaling data:
scaler = ss()
X_train.iloc[:,:5] = scaler.fit_transform(X_train.iloc[:,:5])
X_test.iloc[:,:5] = scaler.transform(X_test.iloc[:,:5])
# %% fitting
clf.fit(X_train,y_train)
# %% Prediction
y_pred = clf.predict(X_test)
# %% Scoring

clf.score(X_test,y_test)

# Weak score of 0.5224. Needs improvements.
# %% B) Cross Validation train Test Split