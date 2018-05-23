#!/usr/bin/python3

import sys
import os
from sklearn.externals import joblib
import numpy as np
import xgboost.sklearn
import csv
import pickle

folder= sys.argv[1]
record = sys.argv[2]
input_file = folder+'/'+record+".csv"

values = []
with open(input_file, 'r') as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)
    for row in csvreader:
        values.append(row)
X=np.array(values)
print(X)


#xgboost_model = pickle.load(open(folder+"xgboost.pkl", "rb" ) )
xgboost_model = joblib.load(folder+'/xgboost_joblib.pkl')
print(type(xgboost_model))
print(xgboost_model)
y = xgboost_model.predict(X)
#print(y)
# Write result to answers.txt
answers_file = open(folder+ "/answers.txt", "a")
record= os.path.basename(record)
answers_file.write("%s,%s\n" % (record, y[0]))
answers_file.close()
# Delete input file (A*****.csv)
os.remove(input_file)