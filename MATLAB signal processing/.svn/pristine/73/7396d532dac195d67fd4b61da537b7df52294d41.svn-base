#! /bin/bash
#
# file: next.sh
#
# This bash script analyzes the record named in its command-line
# argument ($1), and writes the answer to the file 'answers.txt'.
# This script is run once for each record in the Challenge test set.
#
# The program should print the record name, followed by a comma,
# followed by one of the following characters:
#   N   for normal rhythm
#   A   for atrial fibrillation
#   O   for other abnormal rhythms
#   ~   for records too noisy to classify
#
# For example, if invoked as
#    next.sh A00001
# it analyzes record A00001 and (assuming the recording is
# considered to be normal) writes "A00001,N" to answers.txt.

set -e
set -o pipefail
WORKING_DIR=$PWD
RECORD=$1

# Execute ait_challenge_8 in MATLAB to get features and store them to $RECORD.csv
matlab -nodisplay -nodisplay -nosplash -r \
    "     
     try \
	 addpath([pwd,'/ait']);savepath();\
     pars=get_pars(300);\
	 x = ait_challenge_8('$RECORD',pars); \
     catch e; display(getReport(e)); exit(1); end; quit"
	 
	 
# Execute challenge.py to get classification from XGBoost model and store prediction to answers.txt
python3 challenge.py $WORKING_DIR $RECORD
#docker exec -u 0 -it course-xgboost python /notebooks/data/challenge.py $WORKING_DIR $RECORD