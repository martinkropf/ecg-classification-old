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

% data_dir = 'X:\cinc2017\_sources\';
%data_dir = 'C:\temp\cinc2017\';
data_dir = '/Users/mk/cinc2017/';

signals_dir = '/Users/mk/cinc2017/Datasets/nsrdb_30s/';
%% Add this directory to the MATLAB path.
addpath(data_dir);

%% Check for previous files before starting validation procedure


pars=get_pars(300); % fs = 300 Hz
tic;
% Load trained model
model=load(fullfile(data_dir,'last_model.mat'));
files=dir(strcat(signals_dir,'*.hea'));

for i = 1:length(files)
    file = files(i);
    filename=[file.folder,filesep,file.name(1:end-4)];
    %Y_predicted{i}=ait_challenge_8(filename,pars,model.res_model);
    ait_challenge_8(filename,pars);

    copyfile([signals_dir,file.name(1:end-4),'.csv'], '/Users/mk/docker-course-xgboost/notebooks/data/')
    cmd=['system(''/usr/local/bin/docker exec -u 0 -it course-xgboost python /notebooks/data/challenge.py /notebooks/data/ ' file.name(1:end-4) ''');'];
    s = evalc(cmd);
    answer=s(end-4:end-4);
    fprintf('Processing: %s - Prediction: %s\n',filename,answer);
    
end

total_time=toc-tic;
averageTime = total_time/length(RECORDS);
%disp(['Generation of validation set completed.\n  Total time = ' ...
%    num2str(total_time) '\n  Average time = ' num2str(averageTime) '\n']);
%save(fullfile(data_dir,'ait_result_dataset.mat'),'res_dataset');


%Y_predicted=predict(res_model,res_dataset);

%% Write results to answers.txt file
% fid = fopen('answers.txt','w');
% for i=1:length(RECORDS)
% 	fprintf(fid,'%s,%s\r\n',RECORDS{i},Y_predicted{i});
% end
% fclose(fid);
% disp('finished');