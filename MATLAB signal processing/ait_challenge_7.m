function [result,dataPerBeat] = ait_challenge_7(recordName,pars,model,recompute)
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
if nargin<2 | isempty(pars)
    pars=get_pars(300);
end

if nargin<1
    [data_dir,signal_dir]=getLocalProperties();
    recordName=fullfile(signal_dir,'A00001');	% N
end
if isfield(pars,'version') & ~isempty(pars.version)
    resultsFileName=[recordName,'.',mfilename,'.',pars.version]; % store results in a file with the name of the present function and the versioon as the extension
else
    resultsFileName=[recordName,'.',mfilename]; % store results in a file with the name of the present function
end

classifyResult = 'N'; % default output normal rhythm

recNr=eval(recordName(end-4:end));

if ~recompute && exist(resultsFileName,'file')
    fprintf(' ... loading results for signal "%s" ...\r',resultsFileName);
    load(resultsFileName,'-mat'); % supposed to yield all needed results
else
    fprintf(' ... (re)computing "%s" ...\r',resultsFileName);
    
    
    %% Load Signals
    [tm,ecg,fs,siginfo]=rdmat(recordName);
    ws_res.ecgLength=tm(end)-tm(1); % assigned to the work space sourceStructure
    ws_res.ecgAmpMax=max(ecg);
    ws_res.ecgAmpMin=min(ecg);
    ws_res.ecgAmpRange=range(ecg);
    nSamples=size(ecg,1); % number of samples
    
    
    %% Remove spikes
    %ecg_filtered=spike_filter(ecg);
    % ecg=schmidt_spike_removal(ecg,fs);
    % subplot(211), plot(ecg)
    %ecg_filtered=spike_filter(ecg);
    
    % subplot(212), plot(ecg_filtered)
    
    
    %% QRS Detection default
    [QRS,sign,en_thres] = qrs_detect2(ecg',0.25,0.6,fs);
    
    
    %% Flip signal in case of lead inversion
    if isfield(pars,'correct4LeadInversion') && pars.correct4LeadInversion
        if sign<=0
            ecg=ecg*-1;
        end
    end
    
    %% Suppress detection in the initial part of signal (often transients)
    if isfield(pars,'blankSecsAtStart') && ~isempty(pars.blankSecsAtStart) % remove first part of signal - keine Verbesserung (noise wird schlechter)...
        detectOffset=pars.blankSecsAtStart*fs;
    else
        detectOffset=0*fs;
    end
    
    %% QRS Detection AIT
    [QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg(1+detectOffset:end,:),fs,pars);
    QRS2a=QRS2a+detectOffset;
    
    %% Falls die AIT-QRS-Det viel schlechter ist als jene vom CinC Sample Code: Sample Code nehmen
    if isfield(pars,'suppressNonAITqrsDetection') && pars.suppressNonAITqrsDetection == 1 % Gsc 2017-07-02, suppress this if corresponding parameter is available and 1
    else
        rrs_AIT=60./(diff(QRS2a)/fs);
        AIT_rr_irregularity2=length(find(abs(rrs_AIT-median(rrs_AIT))>10))/length(rrs_AIT)*100;
        rrs_CinC=60./(diff(QRS)/fs);
        CinC_rr_irregularity2=length(find(abs(rrs_CinC-median(rrs_CinC))>10))/length(rrs_CinC)*100;
        if CinC_rr_irregularity2> 0 && CinC_rr_irregularity2 < 0.8*AIT_rr_irregularity2
            QRS2a=QRS;
            [QRS2a,amps,qrs_widths]=setFP(QRS2a,ecg,fs,pars);
        end
    end
    
    eventTab.QRS(:,1)=QRS2a;

    
    %% Correlation Classification
    [classes,templates]=corrclass_cinc2017(ecg,QRS2a,fs,pars.corrclass.scw1,pars.corrclass.ccmin1,pars);
    eventTab.Class(:,1)=classes;
    
    if isfield(pars,'detectSpikesMethod') && pars.detectSpikesMethod > 0 % GSc 2017-07-16 - pragmatic detection and removal of isolated spikes, i.e a single different SC in between two events with the same SC
        isSpike=detectSpikes(eventTab,pars);
        eventTab.isSpike(:,1)=isSpike;
    else
        eventTab.isSpike(:,1)=0;        
    end
    ws_res.n_spikes=sum(eventTab.isSpike > 0); % number of spikes in sequence

        
    %% Refine QRS complexes based on classes
    [QRS2,ws_res.numberOfBeatsWithProblems]=refineQRS(ecg,QRS2a,classes,templates,fs,pars.corrclass.scw1);
    
    if isfield(pars,'refineQRScorrMin') && pars.refineQRScorrMin < 1 % GSc 2017-07-15 refine QRS based on cross correlatioln
        [classes,templates]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1,pars); % one more round of standard corr classification
        [QRS3,classes_new]=refineQRS_xcorr(ecg,QRS2,classes,templates,pars.refineQRScorrMin);
        if 0
            figure;
            plot(ecg);
            hold on
            plot(QRS2a,ecg(QRS2a),'sg'); % original
            text(QRS2a,ecg(QRS2a),int2str(classes'),'HorizontalAlignment','right','VerticalAlignment','top'); % refined
            plot(QRS2,ecg(QRS2),'*b'); % refined
            plot(QRS3,ecg(QRS3),'*r'); % refined
            text(QRS3,ecg(QRS3),int2str(classes_new'),'HorizontalAlignment','left','VerticalAlignment','bottom'); % refined
            legend({'ECG','AIT orig','AIT refined','AIT refined new'});
        end
        QRS2=QRS3;
    end
    
    %% Re-calculate correlation classification with refined QRS complexes
    [classes,~,cc_res]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1,pars);
    cc_res.perc_sc1_95=cc_res.perc_sc1;
    cc_res.perc_sc1_95_notNaN=cc_res.perc_sc1_notNaN;
    
    [classes2,~,cc_res2]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw2,pars.corrclass.ccmin2,pars);
    cc_res.perc_sc1_98=cc_res2.perc_sc1;
    cc_res.perc_sc1_98_notNaN=cc_res2.perc_sc1_notNaN;
    
    % GSc 2017-07-02 get rid of any class with less than a minimum number of elements
    if isfield(pars,'deleteClassesLessThan')
        CT=tabulate(classes);
        if ~isempty(CT) % regular classes in the table
            classesLT2=CT(:,2)<pars.deleteClassesLessThan;
            c2d=ismember(classes,CT(classesLT2,1));
            classes(c2d)=nan;
            ws_res.n_singularClasses=sum(classesLT2); % number of classes with less than 2 elements
            ws_res.n_singularBeats=sum(c2d); % number of elements
        else % alll NaN - surrogate values which indicate the inhomogeneity
            ws_res.n_singularClasses=numel(classes); % number of classes with less than 2 elements
            ws_res.n_singularBeats=numel(classes); % number of elements
        end
    end
    
    % GSc 2017-07-14 - analysis of homogeneous sequence, i.e. sequences where all elements belong to the same class
    s=char('0'+classes);
    d=diff(classes);
    s(d~=0)=' ';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_a_row); % do not go below leanth of 1
    ws_res.N_homo_seq_of_more_than_min=sum(I_longEnough); % number of sequences
    ws_res.N_homo_classes_with_seq_of_more_than_min=unique(cellfun(@(x) eval(x(1)), str(I_longEnough))); % unique classes
	if isempty(ws_res.N_homo_classes_with_seq_of_more_than_min)
		ws_res.N_homo_classes_with_seq_of_more_than_min=0;
	end
    ws_res.N_homo_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_homo_rel=sum(str_length)/numel(classes);
    
    % GSc 2017-07-15 - analysis of inhomogeneous sequence, i.e. sequences where all subsequent elements belong to a different class
%    s=char('_'+classes);
    d=diff(classes);
    s=char(repmat('_',1,length(d)));
%    s((d==0) + 1)=' ';
     s(d==0)=' ';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_a_row); % do not go below leanth of 1
    ws_res.N_hetero_seq_of_more_than_min=sum(I_longEnough); % number of sequences
%    ws_res.N_hetero_classes_with_seq_of_more_than_min_max=max(cellfun(@nunique, str(I_longEnough))); % unique classes
    ws_res.N_hetero_classes_with_seq_of_more_than_min_max=max(cellfun(@nunique, str)); % unique classes
    ws_res.N_hetero_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_hetero_rel=sum(str_length)/numel(classes);
    
    
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
    
    %% Calculate combined parameters
    combined_res.afOrNormal=...
        1/90 * af_res.rr_irregularity + ...			1...AF; 0...Normal
        1/80 * (80-rhythm_res.longestNormalSeq) + ...
        1/30 * rhythm_res.n_premajure + ...
        1/14 * rhythm_res.NPa + ...
        rhythm_res.ratio_mean_mov_diff_10 + ...
        1/100 * rhythm_res.iqrs + ...
        1 - rhythm_res.ratioNormal45_100_smooth_c1 + ...
        1 - rhythm_res.ratioRegular10_worstPart_c1 + ...
        1 - rhythm_res.ratioRegular10_bestPart_c1 + ...
        1 - rhythm_res.hist_ratio_diag_c1 + ...
        1 - rhythm_res.perc_regular + ...
        1/100 * af_res.AFEv + ...
        1/90 * (90 - af_res.OriginCount) + ...
        1/100 * af_res.IrrEv + ...
        1/0.2 * (0.2 - av_res.P_amplitude4_1);
    
    % calc normalOrOther
    if rhythm_res.ratioNormal45_100_smooth_c1 <0.6 || ...
            rhythm_res.hr2_c1 > 100 || ...
            rhythm_res.hr2_c1 < 48
        combined_res.normalOrOther = 100;
    else
        combined_res.normalOrOther=...
            1/40 * rhythm_res.nAnyPattern + ...
            1/100 * rhythm_res.range5_95_c1 + ...
            1/10 * rhythm_res.NPv + ...
            1/15 * rhythm_res.Nectopic;
    end
    
    combined_res.afOrNoise=...
        150*rhythm_res.n_hist_all_c1 - ...
        70*rhythm_res.mean_mov_av_diff;
    
    combined_res.is_normal = ...
        af_res.rr_irregularity2 < 50 + ...
        cc_res.ratioSCsUniqueBeforeCorrection < 0.3 + ...
        10 * (rhythm_res.hr2_c1>100 | rhythm_res.hr2_c1<47) + ...	funktioniert sehr gut => *10
        rhythm_res.longestNormalSeq > 7 + ...
        rhythm_res.n_premajure < 8 + ...
        5 * rhythm_res.ratioNormal45_100_c1 > 0.72 + ...			funktioniert sehr gut => *5
        rhythm_res.n_hist_20_c1 < 20 + ...
        rhythm_res.n_hist2 < 10 + ...
        rhythm_res.n_postmajure < 5 + ...
        af_res.AFEv < 25 + ...
        af_res.IrrEv < 25;
    
    combined_res.is_noise = ...
        (1 + qrs_res.dd) + ...							0... no noise; 1...noise
        1/100 * (100-qrs_res.n_not_sel) + ...
        cc_res.ratioSCsUniqueBeforeCorrection  + ...
        cc_res.n_NaN_rel + ...
        cc_res.n_different_in_a_row_95_MAX_rel + ...
        1/100 * (100-cc_res.perc_sc1_notNaN) + ...
        1/16500 * (16500-rhythm_res.nsamp) + ...
        (1 - rhythm_res.sc_gini) + ...
        1/100 * (100-rhythm_res.longestNormalSeq) + ...
        1/30 * (30-rhythm_res.n_premajure) + ...		1/100 * rhythm_res.iqrs + ...
        1/50 * (50-rhythm_res.n_hist_20_c1) + ...
        1/150 * (150-rhythm_res.nBeats_c1) + ...		10 * 1/0.2 * (0.2-av_res.P_amplitude4) + ...
        1/40 * (40 - abs(10-af_res.AFEv)) + ...
        1/100 * (100 - af_res.OriginCount) + ...
        1/10 * noise_res.overallRMS + ...
        1/500 * noise_res.ratio_qrs_outof_width + ...
        1/20 * (10 - noise_res.p_freq_rel_4);
    %
    %
    % 		noise_res.ratio_qrs_different + ...
    % 		(100-noise_res.ratio_avbeat_constant_1) + ...
    % 		100 * (noise_res.max_pause>2) + ...
    % 		noise_res.ratio_qrs_outof_amp + ...
    % 		noise_res.ratio_qrs_outof_width + ...
    % 		noise_res.n_classes_1_beat + ...
    % 		noise_res.ratio_avHighFreq_1 + ...
    % 		(100 - noise_res.av_qrs_rest_ratio_1/5) +...
    % 		noise_res.ratioNaN + ...
    % 		15 * noise_res.overallRMS + ...
    % 		100 * (2 - noise_res.atrial_ratio);
    
    combined_res.n_over_noise_th =...
        (noise_res.ratio_qrs_different > 10) + ...
        (noise_res.ratio_avbeat_constant_1 < 93) + ...
        (noise_res.max_pause > 2) + ...
        (noise_res.ratio_qrs_outof_amp > 5) + ...
        (noise_res.ratio_qrs_outof_width > 5)+ ...
        (noise_res.n_classes_1_beat > 10) + ...
        (noise_res.ratio_avHighFreq_1 > 10) + ...
        (noise_res.av_qrs_rest_ratio_1 < 150);
    
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
    
    if isfield(pars,'addStandardisedEventTimes') % GSc 2017-07-08 - add length normalised event times to calculate event moments later on
        I_nan=isnan(classes');
        dataPerBeat.tMCnorm(:,1)=nan;
        dataPerBeat.tMCnorm(~I_nan,1)=QRS2(~I_nan)'/nSamples;
        dataPerBeat.tNaNnorm(:,1)=nan;
        dataPerBeat.tNaNnorm(I_nan,1)=QRS2(I_nan)'/nSamples;
    end
    
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
    [av_res_names,av_res_values]=getNameAndValues(av_res,'av');
    [noise_res_names,noise_res_values]=getNameAndValues(noise_res,'noise');
    [combined_res_names,combined_res_values]=getNameAndValues(combined_res,'combined');
	[ws_res_names,ws_res_values]=getNameAndValues(ws_res,'ws');
    
    cell_names=['RecID';qrs_res_names;cc_res_names;rhythm_res_names;af_res_names;av_res_names;noise_res_names;combined_res_names;ws_res_names];
    cell_values=[recNr;qrs_res_values;cc_res_values;rhythm_res_values;af_res_values;av_res_values;noise_res_values;combined_res_values;ws_res_values];
    result=cell2dataset(cell_values','VarNames',cell_names');
elseif ~isempty(model)
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

