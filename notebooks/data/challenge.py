#!/usr/bin/python3

import sys
import os
from sklearn.externals import joblib
import numpy as np
import xgboost.sklearn
import csv
import pickle
import pandas as pd

folder= sys.argv[1]
record = sys.argv[2]
input_file_mk = folder+"/"+record+".csv"
#input_file_fa = folder+"/"+record+".fa.csv"

values = []
with open(input_file_mk, 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)
    for row in csvreader:
        values.append(row)
XMK=np.array(values)
print(XMK.shape)

#print(XMK)


print("dataframe")

#df = pd.read_csv(input_file_fa, header = 0)
print("DF original: "+str(XMK.shape))


#XFA=df.values

X=XMK

print(X.shape)

#xgboost_model = pickle.load(open(folder+"xgboost.pkl", "rb" ) )
xgboost_model = joblib.load(folder+'xgboost_joblib.pkl')
print(type(xgboost_model))
print(xgboost_model)
y = xgboost_model.predict(X)
print(y)
# Write result to answers.txt
answers_file = open(folder+ "answers.txt", "a")
record= os.path.basename(record)
answers_file.write("%s,%s\n" % (record, y[0]))
answers_file.close()
# Delete input file (A*****.csv)
os.remove(input_file_mk)
#os.remove(input_file_fa)