import numpy as np
import pandas as pd
from collections import Counter
from sklearn.cross_validation import train_test_split, StratifiedKFold
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
from sklearn.feature_selection import VarianceThreshold
import sklearn
import xgboost
print(sklearn.__version__)
print(xgboost.__version__)

pd.set_option('display.max_columns', 50)
pd.set_option('display.max_rows', 50)
seed = 1234

input_file_mk = "/notebooks/data/ait_result_dataset.V37.csv"
#input_file_fa = "/notebooks/data/fa.csv"

df_mk = pd.read_csv(input_file_mk, header = 0)
#df_fa = pd.read_csv(input_file_fa, header = 0)
#print("df_fa: "+str(df_fa.shape))

df_y=df_mk['target']
#display(df_y)
df_mk=df_mk.drop('target',axis=1)
print("df_mk: "+str(df_mk.shape))



#df_fa=df_fa.replace('NaN',np.nan)
#before=df_fa
df_mk=df_mk.dropna(axis=1, how='all')
#nan_cols=set(before.columns.values)-set(df_fa.columns.values)
#print(nan_cols)
print("DF after dropna: "+str(df_mk.shape))





#df=pd.concat([df_mk,df_fa], axis=1)
#display(df)
df=df_mk
print("df: "+str(df.shape))

#joblib.dump(nan_cols,'nan_cols.pkl')
#print(str(before-after)+ " NaN columns dropped")
#df=df.dropna(axis=1, thresh=len(df) - 10)
#df=df.dropna(axis=0, how='all')
#df=df.replace(np.nan,0)
#display(df)

X=df.as_matrix()
print("X: "+str(X.shape))

y=df_y.as_matrix()
print("y: "+str(y.shape))
#print(y)
#scaler = preprocessing.MinMaxScaler().fit(X)
#X = scaler.transform(X)

#display(pd.DataFrame(X))
#display(pd.DataFrame(y))
#X_before=X
print("X:"+str(X.shape))
imp = Imputer(missing_values='NaN', strategy='mean', axis=0,verbose=1)
imp=imp.fit(X)
X = imp.transform(X)

print("X after imputer:"+str(X.shape))



#pd.DataFrame(X).to_csv('ait_result_dataset.V38.csv', sep=',')
#pd.DataFrame(X).to_excel(writer,'Sheet1')
#writer.save()



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

    # params = {
    #    'objective': 'multi:softmax',
    #    'max_depth': 6,
    #    'learning_rate': 0.1,
    #    'silent': 1,
    #    'n_estimators': 500,
    #    'nthread': 4,
    #    'colsample_bytree': 0.8,
    #    'gamma':0,
    #       'subsample':1,
    #       'min_child_weight':1
    # }
    # 84.53,83.85 (cv)
    
    params = {
        'objective': 'multi:softmax',
        'max_depth': 7,
        'learning_rate': 0.26046515748913901,
        'silent': 0,
        'n_estimators': 110,
        'nthread': 4,
        'colsample_bytree': 0.81958831684028921,
        'gamma':0.25,
        'subsample':0.93168572417786366,
        'min_child_weight':0.9,
        'colsample_bylevel':1,
        'max_delta_step':0,
        'missing':None,
        'reg_alpha':0,
        'scale_pos_weight':1,
    }
    
    print(params)
    #84.33,
    #bst = XGBClassifier(**params)
    bst = XGBClassifier(**params).fit(X, y,verbose=50)
    
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
    joblib.dump(bst, 'xgboost_joblib.pkl', compress = 1)
    
    scorer = make_scorer(f1_score, labels=['A','O','N'], average='macro')
    cv = StratifiedKFold(y, n_folds=5, shuffle=True, random_state=seed)
    scores = cross_val_score(bst, X, y, cv=cv,scoring=scorer)
    print("F1 scores 5-fold CV:",scores)
    print("F1 mean 5-fold CV:",np.mean(scores))
    # save the classifier
    #pickle.dump( bst, open( "xgboost_pickle.pkl", "wb" ) )
    #joblib.dump(scores, 'scores.pkl', compress = 1)

xgboost()


