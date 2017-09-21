#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  6 21:06:26 2017

@author: jams
"""

""" Tentativo di utilizzare Beutifull soup"""

import requests
from bs4 import BeautifulSoup
import re
import pandas as pd
import numpy as np

# URL used: https://www.cia.gov/Library/publications/the-world-factbook/fields/2047.html

url = "https://www.cia.gov/Library/publications/the-world-factbook/fields/2047.html"

req = requests.get(url)

html_doc = req.text

soup = BeautifulSoup(html_doc, "lxml" )

print(req.content)

soup_1 = BeautifulSoup(req.content,"lxml")

print(soup_1)

table=soup_1.find("table", id="fieldListing")
count = []
with open('a.txt', 'w') as f:
    for tr in table('tr', id=True):
        l = list(tr.stripped_strings) #['Afghanistan', 'lowest 10%:', '3.8%', 'highest 10%:', '24% (2008)']
        country = l[0]
        count.append(country)
        highest = l[-1].split()[0]
        f.write(country + ' ' + highest + '\n')

print(soup.title)

text = soup.get_text()

print(text)

link_list = []

for link in soup.find_all('a'):
    link_list.append(link.get('href'))
type(link_list[0])
print(link_list[367])

link_str = str(link_list)
# Nota: nelle Regular Expressions, abbiamo che il primo punto serve al primo carattere, il secondo al secondo e così via!

cc_link = re.findall(r'\/geos/..\.html',link_str)

complete_link = []

for link in cc_link:
    complete_link.append("https://www.cia.gov/Library/publications/the-world-factbook"+link)

new_text = []

for links in complete_link:
    tmp_req_new = requests.get(links)
    tmp_html_doc = tmp_req_new.text
    tmp_soup = BeautifulSoup(tmp_html_doc,"lxml")
    tmp_text = tmp_soup.get_text()
    tmp_text0 = tmp_text.splitlines()
    tmp_text0 = list(filter(None,tmp_text0))
    new_text.append(tmp_text0)

sexy = tmp_soup.contents

print(tmp_soup.contents)

find_data = tmp_soup.find_all('div',{"class":["category","category_data"]})

print(find_data)

find_text = list(find_data)

df = pd.DataFrame()

print(new_text[0])

tmp = [x[239:] for x in new_text]
c_list = []
num_list = []
"""
for coun in tmp:
    for sub in coun:
        if sub.startswith("")
        """
