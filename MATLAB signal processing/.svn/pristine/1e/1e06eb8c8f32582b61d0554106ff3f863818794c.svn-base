
% This script will verify that your code is working as you intended, by
% running it on a small subset (300 records) of the training data, then
% comparing the answers.txt file that you submit with your entry with
% answers produced by your code running in our test environment using
% the same records.
%
% In order to run this script, you should have downloaded and extracted
% the validation set into the directory containing this file.
%
%
% Written by: Chengyu Liu and Qiao Li January 20 2017 
%             chengyu.liu@emory.edu  qiao.li@emory.edu
%
% Last modified by:
%
%

[data_dir,signal_dir,validation_dir]=getLocalProperties();

%% Add this directory to the MATLAB path.
addpath(data_dir);

%% Check for previous files before starting validation procedure

answers = dir('/Users/mk/docker-course-xgboost/notebooks/data/answers.txt');
if(~isempty(answers))
    while(1)
        display(['Found previous answer sheet file in: ' pwd])
        cont = upper(input('Delete it (Y/N/Q)?','s'));
        if(strcmp(cont,'Y') || strcmp(cont,'N') || strcmp(cont,'Q'))
            if(~strcmp(cont,'Y'))
                disp('Exiting script!!')
                return;
            end
            break;
        end
    end
    disp('Removing previous answer sheet.')
    delete('/Users/mk/docker-course-xgboost/notebooks/data/answers.txt');
end
signal_dir=validation_dir;
%% Load the list of records in the validation set.
reffile = [validation_dir, filesep, 'REFERENCE.csv'];
fid = fopen(reffile, 'r');
if(fid ~= -1)
    Ref = textscan(fid,'%s %s','Delimiter',',');
else
    error(['Could not open ' reffile ' for scoring. Exiting...'])
end
fclose(fid);
% Header entfernen
RECORDS = Ref{1};
target  = Ref{2};
N       = length(RECORDS);
pars=get_pars(300); % fs = 300 Hz
tic;




for i = 1:N
   %if mod(i,100)==0
        disp(['processing record ',int2str(i),'/',int2str(length(RECORDS))]);
    %end
    fname = RECORDS{i};
    x=ait_challenge_8([signal_dir,fname],pars);
    copyfile([signal_dir,fname,'.csv'], '/Users/mk/docker-course-xgboost/notebooks/data/')
    cmd=['system(''/usr/local/bin/docker exec -u 0 -it course-xgboost python /notebooks/data/challenge.py /notebooks/data/ ' fname ''');'];
    s = evalc(cmd)
end
total_time=toc-tic;
averageTime = total_time/length(RECORDS);
disp(['Generation of validation set completed.\na Total time = ' ...
   num2str(total_time) '\n  Average time = ' num2str(averageTime) '\n']);

fprintf('Running score2017Challenge.m to get scores on your entry on the validation data in training set....\n');
copyfile('/Users/mk/docker-course-xgboost/notebooks/data/xgboost_joblib.pkl','xgboost_joblib.pkl')
copyfile('/Users/mk/docker-course-xgboost/notebooks/data/answers.txt','answers.txt')

%% Scoring
score2017Challenge


if(strcmp(cont,'Y'))
    disp(['Packaging youra entry (excluding any subdirectories except "ait") to: ' pwd filesep 'entry.zip']);
    % Delete any files if they existed previously
    if (exist('entry.zip','file'))
        delete('entry.zip');
    end
    % This will not package any sub-directories !
    zip('entry.zip',{'*.m','*.c','*.mat','*.txt','*.sh','*.py','*.pkl','ait'});
end
