
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

answers = dir('answers.txt');
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
    delete(answers.name);
end

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
% Load trained model
model=load(fullfile(data_dir,'last_model.mat'));
% import weka.classifiers.Classifier.*;
% import weka.core.*;
% 
% cls = weka.core.SerializationHelper.read("randomcommittee.model");


Y_predicted=cell(N,1);
for i = 1:N
    %if mod(i,100)==0
        disp(['processing record ',int2str(i),'/',int2str(length(RECORDS))]);
    %end
    fname = RECORDS{i};
    Y_predicted(i)=cellstr(ait_challenge_8([signal_dir,fname],pars,model.res_model));
    
end
total_time=toc-tic;
averageTime = total_time/length(RECORDS);
disp(['Generation of validation set completed.\n  Total time = ' ...
   num2str(total_time) '\n  Average time = ' num2str(averageTime) '\n']);
%save(fullfile(data_dir,'ait_result_dataset.mat'),'res_dataset');


%% Write results to answers.txt file
fid = fopen('answers.txt','w');
for i=1:length(RECORDS)
	fprintf(fid,'%s,%s\r\n',RECORDS{i},Y_predicted{i});
end
fclose(fid);

fprintf('Running score2017Challenge.m to get scores on your entry on the validation data in training set....\n');

%% Scoring
score2017Challenge

fprintf('Scoring complete.\n')
while(1)
    disp('Do you want to package your entry for scoring?');
    cont=upper(input('(Y/N/Q)?','s'));
    if(strcmp(cont,'Y') || strcmp(cont,'N') || strcmp(cont,'Q'))
        if(strcmp(cont,'Q'))
            disp('Exiting!!');
            return;
        end
        break;
    end
end

if(strcmp(cont,'Y'))
    disp(['Packaging your entry (excluding any subdirectories except "ait") to: ' pwd filesep 'entry.zip']);
    % Delete any files if they existed previously
    if (exist('entry.zip','file'))
        delete('entry.zip');
    end
    % This will not package any sub-directories !
    zip('entry.zip',{'*.m','*.c','*.mat','*.txt','*.sh','ait'});
end
