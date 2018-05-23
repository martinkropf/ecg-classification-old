
# coding: utf-8

# In[7]:




# ## Imports

# In[8]:

import numpy as np
import pandas as pd
from collections import Counter
from sklearn.cross_validation import train_test_split
from sklearn.metrics import accuracy_score
from xgboost.sklearn import XGBClassifier
from sklearn.tree import DecisionTreeClassifier, export_graphviz
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import Imputer
from sklearn.metrics import log_loss, accuracy_score
from sklearn.metrics import f1_score, precision_score, recall_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score, precision_score, recall_score
from IPython.display import display, HTML
from sklearn.externals import joblib
from sklearn.cross_validation import cross_val_score
from sklearn.metrics import f1_score, make_scorer
import pickle

#from IPython.core.interactiveshell import InteractiveShell
#InteractiveShell.ast_node_interactivity = "all"
pd.set_option('display.max_columns', 500)
seed = 1234


# ## Load dataset / Preprocessing

# In[9]:




input_file = "ait_result_dataset.V38.csv"

df = pd.read_csv(input_file, header = 0)
print("DF original: "+str(df.shape))
#df=df.replace('NaN',np.nan)
before=df.shape[1]
#df=df.dropna(axis=1, how='all')
after=df.shape[1]
#print(str(before-after)+ " NaN columns dropped")


#df=df.dropna(axis=1, thresh=len(df) - 10)
#df=df.dropna(axis=0, how='all')
print("DF after dropna: "+str(df.shape))
df=df.replace(np.nan,0)
#display(df)
numpy_array = df.as_matrix()

n_features=numpy_array.shape[1]
X=numpy_array[:,0:n_features-1]
y=numpy_array[:,n_features-1]

#display(pd.DataFrame(X))
#display(pd.DataFrame(y))

print("X:"+str(X.shape))
#imp = Imputer(missing_values='NaN', strategy='mean', axis=0)
#imp.fit(X)
#X = imp.transform(X)
print("X after imputer:"+str(X.shape))

#display(pd.DataFrame(X))


X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=seed)

print("Train label distribution:")
print(Counter(y_train))

print("\nTest label distribution:")
print(Counter(y_test))

print("\nTrain dataset contains {0} rows and {1} columns".format(X_train.shape[0], X_train.shape[1]))
print("Test dataset contains {0} rows and {1} columns".format(X_test.shape[0], X_test.shape[1]))

def xgboost():
    # ## XGBoost

    # In[183]:

    #params = {
    #    'objective': 'multi:softmax',
    #    'max_depth': 7,
    #    'learning_rate': 0.1,
    #    'silent': 1,
    #    'n_estimators': 200,
    #    'nthread': 4,
    #    'colsample_bytree': 0.8,
    #    'gamma':0,
    #       'subsample':1,
    #       'min_child_weight':1
    #}
    #84.53,83.85 (cv)
    
    params = {
        'objective': 'multi:softmax',
        'max_depth': 9,
        'learning_rate': 0.10836619673151071,
        'silent': 1,
        'n_estimators': 200,
        'nthread': 8,
        'colsample_bytree': 0.27958200096140395,
        'gamma':0.25,
        'subsample':0.93166895175080411,
        'min_child_weight':1,
        'colsample_bylevel':1,
        'max_delta_step':0,
        'missing':None,
        'reg_alpha':0
    }
    #84.33,
    #bst = XGBClassifier(**params)
    bst = XGBClassifier(**params).fit(X, y)
    
    xgb_y_pred = bst.predict(X)

    print("F1: {:1.4f}".format(f1_score(y, xgb_y_pred,labels=['A','O','N'],average='macro')))  

    #display(pd.DataFrame(xgb_y_pred))
    correct = 0

    for i in range(len(xgb_y_pred)):
        if (y[i] == xgb_y_pred[i]):
            correct += 1
    acc = accuracy_score(y, xgb_y_pred)
    print('Predicted correctly: {0}/{1}'.format(correct, len(xgb_y_pred)))
    print('Error: {0:.4f}'.format(1-acc))
    #joblib.dump(bst, 'xgboost.pkl', compress = 1)
    scorer = make_scorer(f1_score, labels=['A','O','N'], average='macro')
    scores = cross_val_score(bst, X, y, cv=5,scoring=scorer)
    print("F1 scores 5-fold CV:",scores)
    print("F1 mean 5-fold CV:",np.mean(scores))
    joblib.dump(bst, 'xgboost.pkl', compress = 1)
    # save the classifier
    pickle.dump( bst, open( "xgboost.pkl", "wb" ) )
    #joblib.dump(scores, 'scores.pkl', compress = 1)

xgboost()

