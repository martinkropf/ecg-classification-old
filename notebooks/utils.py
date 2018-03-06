import pandas as pd
import numpy as np
from sklearn.preprocessing import Imputer
from sklearn.cross_validation import train_test_split
from collections import Counter

def load_data():
    seed=123


    input_file = "../data/ait_result_dataset.V38.csv"
    df = pd.read_csv(input_file, header = 0)
    classes= np.unique(df['target'])

    print("DF original: "+str(df.shape))
    #df=df.replace('NaN',np.nan)
    df=df.dropna(axis=1, how='all')
    #df=df.dropna(axis=1, thresh=len(df) - 10)
    #df=df.dropna(axis=0, how='all')
    print("DF after dropna: "+str(df.shape))
    df=df.replace(np.nan,0)
    df=df.replace('N',0)
    df=df.replace('O',1)
    df=df.replace('A',2)
    df=df.replace('~',3)
    df[['target']] = df[['target']].astype(int)

    #display(df)
    numpy_array = df.as_matrix()
    n_features=numpy_array.shape[1]
    X=numpy_array[:,0:n_features-1]
    y=numpy_array[:,n_features-1]

    #display(pd.DataFrame(X))
    #display(pd.DataFrame(y))

    print("X:"+str(X.shape))
    imp = Imputer(missing_values='NaN', strategy='mean', axis=0)
    imp.fit(X)
    X = imp.transform(X)
    print("X after imputer:"+str(X.shape))

    #display(pd.DataFrame(X))


    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=seed)

    print("Train label distribution:")
    print(Counter(y_train))

    print("\nTest label distribution:")
    print(Counter(y_test))
    #display(df)
    print("\nTrain dataset contains {0} rows and {1} columns".format(X_train.shape[0], X_train.shape[1]))
    print("Test dataset contains {0} rows and {1} columns".format(X_test.shape[0], X_test.shape[1]))
    return df,X,X_train, X_test,y,y_train, y_test