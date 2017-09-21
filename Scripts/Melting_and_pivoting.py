#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  5 17:41:17 2017

@author: Giacomo Matrone
"""

"""
This script has been made in order to melt and pivot data. The dataset features are in italian.
Eventually, two graphs are provided to visualize data.
"""

import os

import numpy as np

import pandas as pd

import datetime

import matplotlib.pyplot as plt

def catch_csv():
    x = os.listdir()
    for i in x:
        if i.endswith(".csv"):
            f = i
            return f

def read_csv_auto():
    name = catch_csv()
    data = pd.read_csv(str(name))
    return data

""" Alternative way to read CSV file:
def read_csv(name):
    data = pd.read_csv(str(name))
    return data
"""

data = read_csv_auto()

name = catch_csv()

data = data[:-1]

data_form = pd.melt(data,["Giorno"],var_name = "Mese", value_name = "Visitatori") 

data_form["Anno"] = 2016
        
data_tidy = data_form[data_form["Visitatori"]>0]        

data_tidy.Giorno = data_tidy.Giorno.astype(int)

data_tidy.info()

gg = ["Domenica","Lunedì","Martedì","Mercoledì","Giovedì","Venerdì","Sabato"]

gg_tot = gg*27

gg_tot = gg_tot[:-5]

data_tidy["Giorno"] = gg_tot
         
date_list = pd.date_range(start= "2016-05-01", end = "2016-10-31")

data_tidy["Data_completa"] = date_list
"""         
data_tidy["Week_Day"] = data_tidy["Data_completa"].dt.weekday_name
         
data_tidy["Month"] = data_tidy["Data_completa"].dt.month_names

data_tidy["Month"] = data_tidy["Data_completa"].dt.strftime("%B")
"""      
grouped = pd.pivot_table(data_tidy, index=["Mese"],columns = "Giorno", values = "Visitatori",aggfunc=np.mean).fillna(0)

index_row = ['MAGGIO ','GIUGNO ','LUGLIO ','AGOSTO','SETTEMBRE ','OTTOBRE ']

index_col = ['Lunedì','Martedì','Mercoledì','Giovedì','Venerdì','Sabato','Domenica']

grouped = grouped.iloc[[3,1,2,0,5,4],[2,3,4,1,6,5,0]]

grouped.plot(kind='bar', figsize = (15,10))   

grouped.plot(kind='area', figsize = (15,10))

