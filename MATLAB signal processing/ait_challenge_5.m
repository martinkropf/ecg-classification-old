function [result,dataPerBeat] = ait_challenge_5(recordName,pars,model,recompute)
%
% Sample entry for the 2017 PhysioNet/CinC Challenge.
%
% INPUTS:
% recordName: string specifying the record name to process
% pars: processing parameters (as calculated in getPars)
% model: pre-trained model which is used for prediction
% recompute: flag which can be 0 (try to load pre-calculated results) or 1
%    re-compute results even if old results are found)
%
% OUTPUTS:
% classifyResult: integer value where
%                     N = normal rhythm
%                     A = AF
%                     O = other rhythm
%                     ~ = noisy recording (poor signal quality)
%
% To run your entry on the entire training set in a format that is
% compatible with PhysioNet's scoring enviroment, run the script
% generateValidationSet.m
%
% The challenge function requires that you have downloaded the challenge
% data 'training_set' in a subdirectory of the current directory.
%    http://physionet.org/physiobank/database/challenge/2017/
%
% This dataset is used by the generateValidationSet.m script to create
% the annotations on your training set that will be used to verify that
% your entry works properly in the PhysioNet testing environment.
%
%
% Version 1.0
%
%
% Written by: Chengyu Liu and Qiao Li January 20 2017
%             chengyu.liu@emory.edu  qiao.li@emory.edu
%
% Last modified by:
%
%

if nargin<4
	recompute=1;
end
if nargin<2
    pars=get_pars(300);
end

if nargin<1
	[data_dir,signal_dir]=getLocalProperties();
    recordName=fullfile(signal_dir,'A05596');	% N
end

classifyResult = 'N'; % default output normal rhythm

recNr=eval(recordName(end-4:end));
RecID=recNr; % just to avoid warning in PM-Pipeline

resultsFileName=[recordName,'.',mfilename]; % store results in a file with the name of the present function as the extension
if ~recompute && exist(resultsFileName,'file')
    fprintf(' ... loading results for signal "%s" ...\r',resultsFileName);
    load(resultsFileName,'-mat'); % supposed to yield all needed results
else
    fprintf(' ... (re)computing "%s" ...\r',resultsFileName);
    
    
    %% Load Signals
    [tm,ecg,fs,siginfo]=rdmat(recordName);
    
    %% Remove spikes
    %ecg_filtered=spike_filter(ecg);
    % ecg=schmidt_spike_removal(ecg,fs);
    % subplot(211), plot(ecg)
    %ecg_filtered=spike_filter(ecg);
    
    % subplot(212), plot(ecg_filtered)
    
    
    %% Remove first 5 s of signal
    % remove first 5 s of signal - keine Verbesserung (noise wird schlechter)...
    % ecg=ecg(5*fs:end);
    
    %% QRS Detection default
    [QRS,sign,en_thres] = qrs_detect2(ecg',0.25,0.6,fs);
    
    
    %% Flip signal in case of lead inversion
    %     if sign<=0
    %         ecg=ecg*-1;
    %     end
    
    %% QRS Detection AIT
    [QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg,fs,pars);
    
    %% Correlation Classification
    [classes,templates]=corrclass_cinc2017(ecg,QRS2a,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
    
    %% Refine QRS complexes based on classes
    QRS2=refineQRS(ecg,QRS2a,classes,templates,fs,pars.corrclass.scw1);

    %% Re-calculate correlation classification with refined QRS complexes
    [classes,~,cc_res]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
    
    [classes2,~,cc_res2]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw2,pars.corrclass.ccmin2);
    cc_res.perc_sc1_98=cc_res2.perc_sc1;
    
% % %     if 0 % GSc 2017-06-06 - remove noise sequence at the beginning
% % % 		for i=1:numel(n_different_in_a_row_min)
% % % 			n_different_in_a_row_95_min_i=n_different_in_a_row_min(i);
% % % 			var_name_i=['n_different_in_a_row_95_min_',int2str(n_different_in_a_row_95_min_i)];
% % % 			eval([var_name_i,'=sum(different_in_a_row_95 > n_different_in_a_row_95_min_i);']); % number of sequences with at least n_different_in_a_row_min
% % % 			cc_res.(var_name_i)=eval(var_name_i); % number of sequences with at least n_different_in_a_row_min
% % % 		end
% % %     
% % %     
% % %     
% % %         cc_res.Nnotdifferent_sc_95=min([find(diff(classes)==0),round(numel(classes)*2/3)]); % keep at least last third of events
% % %         cc_res.Nnotdifferent_sc_98=min([find(diff(classes2)==0),round(numel(classes2)*2/3)]); % keep at least last third of events
% % %         cc_res.Nnotdifferent_sc_min = min(cc_res.Nnotdifferent_sc_95,cc_res.Nnotdifferent_sc_98);
% % %         if cc_res.Nnotdifferent_sc_min > 1 && 0 % get rid of initial sequence with all different classes
% % %             QRS2=QRS2(cc_res.Nnotdifferent_sc_min:end);
% % %             amps=amps(cc_res.Nnotdifferent_sc_min:end);
% % %             qrs_widths=qrs_widths(cc_res.Nnotdifferent_sc_min:end);
% % %             
% % %             classes=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
% % %             cc_res.perc_sc1_95=length(find(classes>1))/length(classes)*100;
% % %             
% % %             classes2=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw2,pars.corrclass.ccmin2);
% % %             cc_res.perc_sc1_98=length(find(classes2>1))/length(classes2)*100;
% % %         end
% % %     end
    

	%% Get Averaged Beat
	[av_res,avbeats]=avbeat_cinc2017(ecg,QRS2,classes,fs,pars);

	%% Rhythm Classification
	[types,rhythm_res]=rhythmclass_cinc2017(ecg,QRS2,classes,amps,qrs_widths,fs,pars,avbeats);

	%% Save Averaged Beats
	% GSc 2017-05-21 - no longer needed is part of the res file now
	%    save([recordName,'_avbeats.mat'],'avbeats','-mat')

	%% Remove Averaged Beat
	atrial_ecg=removeaverage_cinc2017(ecg,QRS2,classes,avbeats,fs,pars);

	%% Detect AF
	af_res=detectaf_cinc2017(ecg,QRS2,QRS,classes,types,atrial_ecg,avbeats,fs,pars);

	%% Detect noise
	noise_res=isnoise_cinc2017(ecg,QRS,QRS2,classes,...
		avbeats,types,amps,qrs_widths,atrial_ecg,fs,pars);

	processedTimeStamp=now;
	
	%% Combine data per beat in a dataset
	dataPerBeat=dataset;
	dataPerBeat.RecID=ones(size(QRS2'))*recNr;
	dataPerBeat.BeatID=[1:length(QRS2)]';
	dataPerBeat.BCI=[NaN;diff(QRS2)'];
	dataPerBeat.QRS=QRS2';
	dataPerBeat.amp=amps;
	dataPerBeat.width=qrs_widths;
	dataPerBeat.corrClass95=classes';
	dataPerBeat.corrClass98=classes2';
	dataPerBeat.rhythmClass=types';
	
	save(resultsFileName);
end


if nargin<3
	% no model available => training mode: return dataset for record
% 	%% Combine data per file in a struct
% 	result=struct(...
% 		'qrs_res',qrs_res,...
% 		'cc_res',cc_res,...
% 		'av_res',av_res,...
% 		'rhythm_res',rhythm_res,...
% 		'af_res',af_res,...
% 		'noise_res',noise_res ...
% 	);
	[qrs_res_names,qrs_res_values]=getNameAndValues(qrs_res,'qrs');
	[cc_res_names,cc_res_values]=getNameAndValues(cc_res,'cc');
	[rhythm_res_names,rhythm_res_values]=getNameAndValues(rhythm_res,'rhythm');
	[af_res_names,af_res_values]=getNameAndValues(af_res,'af');
	[noise_res_names,noise_res_values]=getNameAndValues(noise_res,'noise');

	cell_names=['RecID';qrs_res_names;cc_res_names;rhythm_res_names;af_res_names;noise_res_names];
	cell_values=[recNr;qrs_res_values;cc_res_values;rhythm_res_values;af_res_values;noise_res_values];
	result=cell2dataset(cell_values','VarNames',cell_names');
else
    %evaluation mode: return prediction for record based on given model
    ds=double(cell2dataset(cell_data,'VarNames',varNames));
    %TODO: fix this
    load('vars2use.mat')
    
    ds=ds(:,find(vars2use));
    %display(ds);
    result=predict(model,ds);
end
end


function [names,values] = getNameAndValues(input_struct,struct_name)
	all_fieldnames=fieldnames(input_struct);
	names=all_fieldnames;
	for i=1:length(all_fieldnames)
		cur_fieldname=all_fieldnames{i};
		names{i}=[struct_name,'_',cur_fieldname];
%  		disp([cur_fieldname,char(9),struct_name,'_res',char(9)]);
% 		disp([names{i}]);
	end
	values=struct2cell(input_struct);
end

