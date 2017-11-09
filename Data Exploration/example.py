# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 14:36:47 2017

@author: Giacomo
"""
#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
import re
from datetime import datetime
os.getcwd()

os.chdir('whatever')
#%%
data1 = pd.read_excel("Data set #1.xlsx")
                      
data1["Trip date and time"] = pd.to_datetime(data1["Trip date and time"])

data1.set_index("Trip date and time",inplace = True)

data2 = pd.read_excel("Data set #2.xlsx")

orig2 = list(data2.columns)
                      
new2 = ['date','hour','times_xxxxx_open','completed_trips','unocc_cpt','missed_book']

data2.columns = new2

data2.iloc[:,0]= data2.iloc[:,0]+"-2015"                         
                     
data2['date'] = pd.to_datetime(data2['date'],format = "%d-%b-%Y")

data2['weekday'] = data2['date'].apply(lambda x: x.weekday())                                   

new2 = ['date','hour','times_xxxxx_open','completed_trips','unocc_cpt','missed_book']

dict_leg2 = dict(zip(orig2,new2))              
                      
data3 = pd.read_excel("Data set #3.xlsx")

data1.loc[data1.index<"2015-10-04",]

#%%
colnames = list(data1.columns.values)

suffix = [re.findall('\(.*?\)',x) for x in colnames]

short = [re.sub(r' \(.*?\)',"",string=x) for x in colnames]

short = [re.sub(r' ',"_",x) for x in short]

short = [re.sub(r'[aeiou]',"",x) for x in short]

short = [x[:15] for x in short]

dict_leg = dict(zip(colnames,short))

data1.columns = short
#%%
data1.Cty = data1.Cty.str[:3]

names = list(data1.Cty.unique())
#%%
grouped_fin_city = pd.pivot_table(data1,columns =dict_leg['City'], values = [dict_leg['Trip price (€)'],dict_leg['Captain earnings (€)']],index=[dict_leg['Payment method'],dict_leg['Car type']])
grouped_fin_city_tot = pd.pivot_table(data1,columns =dict_leg['City'], values = [dict_leg['Trip price (€)'],dict_leg['Captain earnings (€)']],index=[dict_leg['Payment method'],dict_leg['Car type']],aggfunc=sum)
#%%
# Question 1

data1.groupby(dict_leg['City'])[dict_leg['Trip ID']].count()/data1[dict_leg['Trip ID']].count()
#%%
# Question 2

data1.loc[data1[dict_leg['City']] == names[0],dict_leg["Trip ID"]].count()/data1.loc[data1[dict_leg['City']] == names[2],dict_leg["Trip ID"]].count()-1


#%%
# Question 3

first = data1.loc["2015-10-01":"2015-10-03",'Trp_ID'].count()

second = data1.loc["2015-10-04":"2015-10-06",'Trp_ID'].count()

third = data1.loc["2015-10-06":"2015-10-08",'Trp_ID'].count()

fourth = data1.loc["2015-10-08":"2015-10-10",'Trp_ID'].count()

fifth = data1.loc["2015-10-10":"2015-10-12",'Trp_ID'].count()
#%%
# Question 4

data1['weekday'] = data1.index.weekday

# Data over the total:

data1.groupby(dict_leg['Car type'])[dict_leg['Trip ID']].count()/data1[dict_leg['Trip ID']].count()
                      
data1.groupby([dict_leg['City'],dict_leg['Car type']])[dict_leg['Trip ID']].count()/data1[dict_leg['Trip ID']].count()

grouped_weekday = pd.pivot_table(data1,columns =dict_leg['City'], values = [dict_leg['Trip price (€)'], dict_leg['Captain earnings (€)']],index=['weekday',dict_leg['Car type']],aggfunc=sum)

grouped_weekday_gen = pd.pivot_table(data1,columns =dict_leg['City'], values = [dict_leg['Trip price (€)'], dict_leg['Total trip duration (mins)'], dict_leg['Distance travelled (km)'],dict_leg['Captain wait time for customer at pickup (mins)'],dict_leg['Captain earnings (€)']],index=['weekday',dict_leg['Car type']],aggfunc=np.mean)
#%%
# row labels preparation:

grouped_norm_gen = grouped_weekday_gen.apply(lambda x: (x - np.mean(x))/(np.max(x) - np.min(x)))
#%%
sns.heatmap(grouped_norm_gen)

plt.xticks(rotation = 45,ha='right')
# plt.figure(70,70)
plt.title("Captain data by day and class")
plt.xlabel('data by city')
plt.ylabel('data by week, day and class')
plt.tight_layout()
plt.savefig('xxxxx heatmap.png', dpi = 900) #bbox_inches parameter allows for saving non cutted image.
plt.show()

#%% Data in days (data2)

data2_norm_gen = data2.iloc[:,2:].apply(lambda x: (x - np.mean(x))/(np.max(x) - np.min(x)))
data2_norm_gen = pd.concat([data2.iloc[:,0:2],data2_norm_gen],axis = 1)
#sns.set(style = 'ticks')
#%% Graph
sns.violinplot(y = 'missed_book',x='weekday',data=data2,color='grey',alpha = 0.5)
sns.swarmplot(y = 'missed_book',x='weekday',data=data2)
plt.xticks(rotation = 0)
plt.title('Missed Booking distribution by day')
plt.xlabel('Weekday (0 = Monday)')
plt.ylabel('Number of Missed Bookings')
plt.savefig('xxxxx violin.png', dpi = 900)
plt.show()

#%% Threshold setting

output =[]

for x in data2_norm_gen['missed_book']:
    if x > 0.5:
        output.append(1)
    elif x < -0.5:
        output.append(-1)
    elif x > -0.5 and x < 0.5:
        output.append(0)
#%%

data_ml = pd.DataFrame(data2_norm_gen)

data_ml1 = data_ml.drop(['missed_book',"date"],axis = 1)

from sklearn.model_selection import train_test_split as tts

x_train1,x_test1,y_train1,y_test1 = tts(data_ml1,output)

from sklearn.neighbors import KNeighborsClassifier as knc

cla = knc()

cla.fit(x_train1,y_train1)

pred = cla.predict(x_test1)     

from sklearn.metrics import accuracy_score as ac

acc = ac(y_test1,pred)   

#%% Plotting hexbin for data 2 and patterns

day_section = []

for i in data2.hour:
    if i >=0 and i <3:
        day_section.append('night')
    elif i >= 3 and i < 6:
        day_section.append('deep night')
    elif i >= 6 and i < 9:
        day_section.append('earl morning')
    elif i >= 9 and i < 12:
        day_section.append('morning rush')
    elif i >= 12 and i <15:
        day_section.append('early noon')
    elif i >= 15  and i <18:
        day_section.append('afternoon')
    elif i >= 18 and i <21:
        day_section.append('dinner')
    elif i >= 21:
        day_section.append('earl night')

data2['day_section'] = day_section

data2['percentage'] = data2.iloc[:,3:].sum(axis = 1).divide(data2['times_xxxxx_open'])

pattern = data2.loc[data2.percentage > 1,:]

plt.figure()
plt.subplot(2,1,1)
sns.set(style ='darkgrid' )
sns.violinplot(y = 'missed_book',x='weekday',data=data2,color='grey',alpha = 0.5)
sns.swarmplot(y = 'missed_book', x= 'weekday',hue = 'day_section',data=data2)
plt.title('Missed bookings per hour day long')
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

plt.subplot(2,1,2)
sns.set(style ='darkgrid' )
sns.violinplot(y = 'missed_book',x='weekday',data=pattern,color='grey',alpha = 0.5)
sns.swarmplot(y = 'missed_book', x= 'weekday',hue = 'day_section',data=pattern)
plt.title('Missed bookings per hour day long [zoomed]')
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

plt.tight_layout()
plt.savefig('data dispersion_zoomed.png', dpi = 900,bbox_inches = 'tight')

plt.show()                              
