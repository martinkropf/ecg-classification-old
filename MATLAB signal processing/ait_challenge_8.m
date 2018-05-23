function [result,dataPerBeat] = ait_challenge_8(recordName,pars,model,recompute)
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
if nargin<2 || isempty(pars)
    pars=get_pars(300);
end

if nargin<1
    [data_dir,signal_dir]=getLocalProperties();
    recordName=fullfile(signal_dir,'A00001');	% N
end
if isfield(pars,'version') && ~isempty(pars.version)
    resultsFileName=[recordName,'.',mfilename,'.',pars.version]; % store results in a file with the name of the present function and the versioon as the extension
else
    resultsFileName=[recordName,'.',mfilename]; % store results in a file with the name of the present function
end

classifyResult = 'N'; % default output normal rhythm
eventTab=table; % intitialise
disp(recordName);
%recNr=eval(recordName(end-4:end));
recNr=recordName;

if ~recompute && exist(resultsFileName,'file')
    fprintf(' ... loading results for signal "%s" ...\r',resultsFileName);
    load(resultsFileName,'-mat'); % supposed to yield all needed results
else
%     fprintf(' ... (re)computing "%s" ...\r',resultsFileName);
    
    
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
    
    
    %% Suppress detection in the initial part of signal (often transients)
    detectOffset=pars.blankSecsAtStart*fs;
	
	if pars.doInitialFiltering
		[b,a]=butter(2,[0.05,35]*2/fs,'bandpass');
		ecg=filtfilt(b,a,ecg);
	end
    
    %% QRS Detection default
    [QRS1,sign,en_thres] = qrs_detect2(ecg(1+detectOffset:end,:)',0.25,0.6,fs);
    QRS1=QRS1+detectOffset;
    
    %% QRS Detection AIT
    [QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg(1+detectOffset:end,:),fs,pars);
	if length(QRS2a)<2
		pars.detectevents.doGini=0;
		[QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg(1+detectOffset:end,:),fs,pars);
	end
    QRS2a=QRS2a+detectOffset;
	
	%% Flip singal in case of lead inversion 
	[isInverted, doInversion, inv_res]=checkForLeadInversion(ecg,QRS2a,fs,sign,pars);
	if doInversion
		ecg=-ecg;
		[QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg(1+detectOffset:end,:),fs,pars);
		QRS2a=QRS2a+detectOffset;
		inversionDone=1;
	else
		inversionDone=0;
	end
	
	rrs_AIT=60./(diff(QRS2a)/fs);
	AIT_rr_irregularity2=length(find(abs(rrs_AIT-median(rrs_AIT))>10))/length(rrs_AIT)*100;
	
	%% QRS-Det funktionierte schlecht => mit hoeherer HR-max versuchen
	if AIT_rr_irregularity2>0.1
		pars2=pars;
		pars2.detectevents.nmax=pars.detectevents.nmax*1.3;
		[QRS2b,amps_b,qrs_widths_b,qrs_res_b]=detectevents_cinc2017(ecg(1+detectOffset:end,:),fs,pars2);
		QRS2b=QRS2b+detectOffset;
		rrs_AITb=60./(diff(QRS2b)/fs);
		AIT_rr_irregularity2b=length(find(abs(rrs_AITb-median(rrs_AITb))>10))/length(rrs_AITb)*100;
		if AIT_rr_irregularity2b < AIT_rr_irregularity2
			QRS2a=QRS2b;
			amps=amps_b;
			qrs_widths=qrs_widths_b;
			qrs_res=qrs_res_b;
			AIT_rr_irregularity2=AIT_rr_irregularity2b;
		end 
	end
    
    %% Falls die AIT-QRS-Det viel schlechter ist als jene vom CinC Sample Code: Sample Code nehmen
    if ~pars.suppressNonAITqrsDetection % Gsc 2017-07-02, suppress this if corresponding parameter is available and 1
        rrs_CinC=60./(diff(QRS1)/fs);
        CinC_rr_irregularity2=length(find(abs(rrs_CinC-median(rrs_CinC))>10))/length(rrs_CinC)*100;
        if CinC_rr_irregularity2>0 && CinC_rr_irregularity2 < 0.8*AIT_rr_irregularity2
            QRS2a=QRS1;
			[QRS2a,amps,qrs_widths]=setFP(QRS2a,ecg,fs,pars);
        end
    end
    
    eventTab.QRS=QRS2a';
    eventTab.isSpike(:,1)=0; % initialise

    
    %% Correlation Classification - 1st pass
    [classes1,templates]=corrclass_cinc2017(ecg,QRS2a,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
	if ~isempty(classes1)
		eventTab.classes1(:,1)=classes1';
	end
    
    if pars.detectSpikesPosition==0
		if isfield(pars,'detectSpikesMethod') && pars.detectSpikesMethod > 0 % GSc 2017-07-16 - pragmatic detection and removal of isolated spikes, i.e a single different SC in between two events with the same SC
	 %           isSpike=detectSpikes(eventTab,pars);
				isSpike=detectSpikes(eventTab.classes1,eventTab.QRS,pars);
			eventTab.isSpike(:,1)=isSpike;
		end
		ws_res.n_spikes=sum(eventTab.isSpike > 0); % number of spikes in sequence
    end

    %% Refine QRS complexes based on classes
    [QRS2,ws_res.numberOfBeatsWithProblems]=refineQRS(ecg,QRS2a,classes1,templates,fs,pars.corrclass.scw1);
    eventTab.QRS2=QRS2';        
    
    QRS3=QRS2;
    if isfield(pars,'refineQRScorrMin') && pars.refineQRScorrMin < 1 % GSc 2017-07-15 refine QRS based on cross correlatioln
        [classes2,beatTemplates2]=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1); % one more round of standard corr classification
        [QRS3,classes3]=refineQRS_xcorr(ecg,QRS2,classes2,beatTemplates2,pars.refineQRScorrMin);
        beatTemplates3=beatTemplates2;
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
    else
        classes2=classes1;
        [classes3,beatTemplates3]=corrclass_cinc2017(ecg,QRS3,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
        [classes_98]=corrclass_cinc2017(ecg,QRS3,fs,pars.corrclass.scw2,pars.corrclass.ccmin2);
	end
	if ~isempty(classes2)
		eventTab.classes2(:,1)=classes2';
	end
	if ~isempty(QRS3)
		eventTab.QRS3=QRS3';
		eventTab.classes3(:,1)=classes3';
	end

    %% Re-arrange correlation classification and calculate parameters with refined QRS complexes
    [classes,beatTemplates,cc_res]=corrclass_cinc2017_results(QRS3,classes3,beatTemplates3);
    
    %     [classes_98,~,cc_res2]=corrclass_cinc2017(ecg,QRS3,fs,pars.corrclass.scw2,pars.corrclass.ccmin2,pars,providedClasses);
    %     cc_res.perc_sc1_98=cc_res2.perc_sc1;
    %     cc_res.perc_sc1_98_notNaN=cc_res2.perc_sc1_notNaN;

    % GSc 2017-07-02 get rid of events from any class with less than a minimum number of elements
    isMemberOfLesserClass=zeros(size(eventTab(:,1)));
    classesWithMembersLessThan=0;
    if isfield(pars,'deleteClassesLessThan')
        CT=tabulate(classes);
        if ~isempty(CT) % regular classes in the table
            classesWithMembersLessThan=CT(:,2)<pars.deleteClassesLessThan;
            c2d=ismember(classes,CT(classesWithMembersLessThan,1));
%            classes(c2d)=nan;
            isMemberOfLesserClass(c2d)=1;
        else % all NaN - surrogate values which indicate the inhomogeneity
        end
    end
    eventTab.isLesserClass=isMemberOfLesserClass;
    ws_res.N_lesserClass=sum(classesWithMembersLessThan); % number of classes with less than 2 elements
    ws_res.n_isMemberOfLesserClass=sum(isMemberOfLesserClass); % number of elements
    
    % GSc 2017-07-14 - analysis of homogeneous sequence, i.e. sequences where all elements belong to the same class
    s=char('0'+classes);
%    d=diff(classes);
    d=[diff(classes),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2    
    s(d~=0)=' ';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_a_row); % do not go below length of 1
    ws_res.N_homo_seq_of_more_than_min=sum(I_longEnough); % number of sequences
    ws_res.N_homo_classes_with_seq_of_more_than_min=nunique(cellfun(@(x) eval(x(1)), str(I_longEnough))); % unique classes
    ws_res.N_homo_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_homo_rel=sum(str_length)/numel(classes);
    
    % GSc 2017-07-15 - analysis of inhomogeneous sequence, i.e. sequences where all subsequent elements belong to a different class
%    s=char('_'+classes);
%    d=diff(classes);
    d=[diff(classes),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2    
    s=char(classes+'!');
     s(d==0)=' ';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_a_row); % do not go below length of 1
    ws_res.N_hetero_seq_of_more_than_min=sum(I_longEnough); % number of sequences
    ws_res.N_hetero_classes_with_seq_of_more_than_min_max=max(cellfun(@nunique, str)); % unique classes
    ws_res.N_hetero_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_hetero_rel=sum(str_length)/numel(classes);
    I_seq2nan=find(I_longEnough);
    for i=1:numel(I_seq2nan) % set MC for elements of those sequences to NaN
        ss=strfind(s,str(I_seq2nan(i)));
        for j=1:numel(ss) % smae seqence could occure multiple times
            seq2beReplaced=classes(ss(j)+[1:str_length(I_seq2nan(i))]-1);
            if sum(seq2beReplaced==mode(seq2beReplaced)) < length(seq2beReplaced)/2;% request that sequence contains not more than 1/3 mainclass events - otherwise bigeminus would be nan'd
                classes(ss(j)+[1:str_length(I_seq2nan(i))-1])=nan;
            end
        end
    end
    
    [classes,beatTemplates]=sortClasses(classes,beatTemplates); % sort classes according to their frequency of occurence
    
    if pars.detectSpikesPosition==1 % moved to here from above
		eventTab.isSpike(:,1)=0; % initialise
        if isfield(pars,'detectSpikesMethod') && pars.detectSpikesMethod > 0 % GSc 2017-07-16 - pragmatic detection and removal of isolated spikes, i.e a single different SC in between two events with the same SC
            isSpike=detectSpikes(classes,QRS3,pars);
            eventTab.isSpike(isSpike==1,1)=1;
        end
        ws_res.n_spikes=sum(eventTab.isSpike > 0); % number of spikes in sequence
    end
    
    hclasses=[1,classes,1];
    s=char('!'+hclasses);
    d=[diff(hclasses),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2    
    d(hclasses(1:end-1)==1 - 1)=0;
    s(d==0)=' ';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length==3; % 3 different in a row
    ws_res.N_seq_of_2_non1inArow=sum(I_longEnough); % number of sequences
    if isfield(pars,'detectSpikesMethod') && pars.detectSpikesMethod == 4 % GSc 2017-08-15 - removal of 2-sequences of non 1 classes
        I_seq2nan=find(I_longEnough);
        for i=1:numel(I_seq2nan) % set MC for elements of those sequences to NaN
            ss=strfind(s,str(I_seq2nan(i)));
            for j=1:numel(ss) % smae seqence could occure multiple times
                seq2beReplaced=hclasses(ss(j)+[1:str_length(I_seq2nan(i))]);
                if seq2beReplaced(2)~=1 % dont do it if the middle event is mainclass
                    I2nan=ss(j)+find(seq2beReplaced>1);
                    eventTab.isSpike(I2nan,1)=1;
                    classes(I2nan)=nan;
                end
            end
        end
    end
     
    [classes,beatTemplates]=sortClasses(classes,beatTemplates); % sort classes according to their frequency of occurence
       
    % set to nan all problematic events
    I_2nan = eventTab.isSpike | eventTab.isLesserClass;
    classes(I_2nan)=nan;
    QRS3(I_2nan)=nan;
    eventTab.BCI=[NaN;diff(QRS3)'];
    
    eventTab.classes(:,1)=classes';
    
    % GSc 2017-08-07 - use BCI estimate to reduce search area for p wave -
    % no longer needed here - moved to inside avbeat_cinc2017
    %    pars.BCI_est=mean(eventTab.BCI,'omitnan');
    
    d=[diff(classes),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2    
    if pars.n_min_for_tachy>0 % GSc 2017-08-12 - use BCI and sequencing to detect temporary tachycardia
        s=char(repmat(' ',1,length(classes)));
        %        s(eventTab.BCI<fs*60/100 & ~isnan(eventTab.classes))='|'; % ignore nan
%        s(eventTab.BCI<fs*60/100 & [d,nan]'==0)='|'; % ignore class changes
        s(eventTab.BCI<fs*60/pars.tachy_bpm & d'==0)='|'; % ignore class changes
        [str,matches]=split(s);
        str_length=cellfun(@length,str);
        I_longEnough=str_length>=max(1,pars.n_min_for_tachy); % number of subsequent beats to define tachycardia
        ws_res.N_tachy=sum(I_longEnough); % number of tachy sequences
        ws_res.N_tachy_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
        ws_res.N_tachy_rel=sum(str_length)/numel(classes);
	else
		ws_res.N_tachy_max_beats_in_a_row=0;
    end
    
    if pars.n_min_for_brady>0 % GSc 2017-08-12 - use BCI and sequencing to detect temporary bradycardia
        s=char(repmat(' ',1,length(classes)));
        s(eventTab.BCI>fs*60/pars.brady_bpm)='|';
        [str,matches]=split(s);
        str_length=cellfun(@length,str);
        I_longEnough=str_length>=max(1,pars.n_min_for_brady); % number of subsequent beats to define bradycardia
        ws_res.N_brady=sum(I_longEnough); % number of brady sequences
        ws_res.N_brady_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
        ws_res.N_brady_rel=sum(str_length)/numel(classes);
	else
		ws_res.N_bradyy_max_beats_in_a_row=0;
    end
    
    %% Get Averaged Beat
	[av_res,avbeats]=avbeat_cinc2017(ecg,QRS3,classes,fs,pars,isInverted ~= inversionDone);
    
    %% Rhythm Classification
    [types,rhythm_res]=rhythmclass_cinc2017(ecg,QRS3,classes,amps,qrs_widths,fs,pars,avbeats);
    eventTab.types=types';
    
    %% Save Averaged Beats
    % GSc 2017-05-21 - no longer needed is part of the res file now
    %    save([recordName,'_avbeats.mat'],'avbeats','-mat')
    
    %% Remove Averaged Beat
    [atrial_ecg,atrial_ecg2,remav_res]=removeaverage_cinc2017(ecg,QRS3,classes,avbeats,fs,pars);
    
    %% Detect AF
    af_res=detectaf_cinc2017(ecg,QRS3,QRS1,classes,types,atrial_ecg,atrial_ecg2,avbeats,fs,pars);
    
    %% Detect noise
    noise_res=isnoise_cinc2017(ecg,QRS1,QRS3,classes,...
        avbeats,types,amps,qrs_widths,atrial_ecg,fs,pars);
    
	%% Calculate corr of P and QRS with AV Beat
	[Pcorr,PrmsAV,PrmsZero]=beatParameters(ecg,QRS3,classes,...
		round(pars.beatParameters.Pwindow*fs),round(pars.beatParameters.rp*fs),...
		isInverted ~= inversionDone,avbeats);
	PCorrRes=findCommonPatterns(Pcorr);
	PAVRes=findCommonPatterns(PrmsAV);
	PZeroRes=findCommonPatterns(PrmsZero);
	allFieldnames=fieldnames(PCorrRes);
	for i=1:length(allFieldnames)
		cur_fieldname=allFieldnames{i};
		Pres.(['corr_',cur_fieldname])=PCorrRes.(cur_fieldname);
		Pres.(['rmsav_',cur_fieldname])=PAVRes.(cur_fieldname);
		Pres.(['rmszero_',cur_fieldname])=PZeroRes.(cur_fieldname);
	end
% 	Pres.ratioCorrAvZero=mean(PrmsAV(isfinite(PrmsAV) & isfinite(PrmsZero))./...
% 		PrmsZero(isfinite(PrmsAV) & isfinite(PrmsZero)));
	
	[QRScorr]=beatParameters(ecg,QRS3,classes,...
		round(pars.beatParameters.QRSwindow*fs),round(pars.beatParameters.rp*fs),...
		isInverted ~= inversionDone,avbeats);
	QRSres=findCommonPatterns(QRScorr);
	
	%% Combine data per beat in a dataset
    dataPerBeat=dataset;
    dataPerBeat.RecID=ones(size(QRS3'))*recNr;
    dataPerBeat.BeatID=[1:length(QRS3)]';
    dataPerBeat.BCI=[NaN;diff(QRS3)'];
    dataPerBeat.QRS=QRS3';
    dataPerBeat.amp=amps;
    dataPerBeat.width=qrs_widths;
    dataPerBeat.corrClass95=classes';
	dataPerBeat.Pcorr=Pcorr';
	dataPerBeat.PAVRes=PrmsAV';
	dataPerBeat.PZeroRes=PrmsZero';
	dataPerBeat.QRScorr=QRScorr';
    %    dataPerBeat.corrClass98=classes_98';
    dataPerBeat.rhythmClass=types';
	
	commonPattern_res=getCommonPatternPars(dataPerBeat);
    
	if isfield(pars,'addStandardisedEventTimes') % GSc 2017-07-08 - add length normalised event times to calculate event moments later on
		dataPerBeat.tMCnorm=ones(size(dataPerBeat.corrClass95))*NaN;
		dataPerBeat.tNaNnorm=ones(size(dataPerBeat.corrClass95))*NaN;
		I_nan=isnan(classes');
		dataPerBeat.tMCnorm(~I_nan,1)=QRS3(~I_nan)'/nSamples;
		dataPerBeat.tNaNnorm(I_nan,1)=QRS3(I_nan)'/nSamples;
	end
	
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
        combined_res.normalOrOther = 1000;
    else
        combined_res.normalOrOther=...
            100*ws_res.N_brady_max_beats_in_a_row + ...
			2*ws_res.N_tachy_max_beats_in_a_row + ...
			15*min(12,rhythm_res.nAnyPattern) - ...
			50*rhythm_res.ratioNormal45_100_c1 + ...
			5 * rhythm_res.perc_regular - ...
			0.1*rhythm_res.longestNormalSeq + ...
			rhythm_res.Nectopic + ...
			10*av_res.nOtherRhythmBeats + ...
			0.75 *rhythm_res.hrtrt + ...
			200 *rhythm_res.ratioSlow50+ ...
			200*rhythm_res.ratioFast100 + ...
			100*rhythm_res.ratioRegular1 -...
			30*ws_res.N_seq_of_2_non1inArow + ...
			350*ws_res.N_homo_rel;
	end
	if rhythm_res.ratioNormal45_100_smooth_c1 <0.6 || ...
            rhythm_res.hr2_c1 > 100 || ...
            rhythm_res.hr2_c1 < 48
        combined_res.normalOrOther_old = 100;
    else
        combined_res.normalOrOther_old=...
            1/40 * rhythm_res.nAnyPattern + ...
            1/100 * rhythm_res.range5_95_c1 + ...
            1/10 * rhythm_res.NPv + ...
            1/15 * rhythm_res.Nectopic + ...
			av_res.nOtherRhythmBeats;
	end
%     
%     combined_res.afOrNoise=...
%         150*rhythm_res.n_hist_all_c1 - ...
%         70*rhythm_res.mean_mov_av_diff;
	
	combined_res.afOrNoise=...
        3*rhythm_res.n_hist_all_c1 - ...
        15*av_res.P_angle_1 - ...
		200*av_res.P_amplitude4_1;
	
    combined_res.is_normal = ...
        double(af_res.rr_irregularity2 < 50) + ...
        double(cc_res.ratioSCsUniqueBeforeCorrection < 0.3) + ...
        10 * double (rhythm_res.hr2_c1<100 & rhythm_res.hr2_c1>47) + ...	funktioniert sehr gut => *10
        double(rhythm_res.longestNormalSeq > 7) + ...
        double(rhythm_res.n_premajure < 8) + ...
        5 * double(rhythm_res.ratioNormal45_100_c1 > 0.72) + ...			funktioniert sehr gut => *5
        double(rhythm_res.n_hist_20_c1 < 20) + ...
        double(rhythm_res.n_hist2 < 10) + ...
        double(rhythm_res.n_postmajure < 5) + ...
		double(rhythm_res.perc_regular>40) + ...
		double(rhythm_res.perc_postmajure<20) + ...
		double(rhythm_res.perc_premajure<30) + ...
		double(rhythm_res.N_bci_decreases_1_times<30) + ...
		double(rhythm_res.N_bci_increases_1_times<30) + ...
		double(qrs_res.I_Gmin<100) + ...
		double(rhythm_res.NDelayed<8) + ...
		double(rhythm_res.imbalance>=-5) + ...
        double(af_res.AFEv < 25) + ...
        double(af_res.IrrEv < 25) + ...
		double(ws_res.N_tachy_max_beats_in_a_row<8) + ...
		double(ws_res.N_brady_max_beats_in_a_row<2);
	
	combined_res.is_normal_old = ...
        double(af_res.rr_irregularity2 < 50) + ...
        double(cc_res.ratioSCsUniqueBeforeCorrection < 0.3) + ...
        10 * double (rhythm_res.hr2_c1>100 | rhythm_res.hr2_c1<47) + ...	funktioniert sehr gut => *10
        double(rhythm_res.longestNormalSeq > 7) + ...
        double(rhythm_res.n_premajure < 8) + ...
        5 * double(rhythm_res.ratioNormal45_100_c1 > 0.72) + ...			funktioniert sehr gut => *5
        double(rhythm_res.n_hist_20_c1 < 20) + ...
        double(rhythm_res.n_hist2 < 10) + ...
        double(rhythm_res.n_postmajure < 5) + ...
        double(af_res.AFEv < 25) + ...
        double(af_res.IrrEv < 25);
    
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
	
	bci=diff(QRS3);
	beat_res=struct(...
		'amp_skewness',skewness(amps(isfinite(amps))),...
		'amp_gini',ginicoeff(amps(isfinite(amps))),...
		'bci_skewness',skewness(bci(isfinite(bci))),...
		'bci_gini',ginicoeff(bci(isfinite(bci))),...
		'width_skewness',skewness(qrs_widths(isfinite(qrs_widths))),...
		'width_gini',ginicoeff(qrs_widths(isfinite(qrs_widths))));
    
	combined_res.normalOrOther_new=-60*(af_res.AFEv>5) -100*(af_res.OriginCount>48)-700*(af_res.p_af_freq_1.*af_res.p_af_freq_3./af_res.p_af_freq_6>0.055) + 500*(af_res.pp_irregularity2<34) +  100*ws_res.N_brady_max_beats_in_a_row + 2*ws_res.N_tachy_max_beats_in_a_row+150*min(12,rhythm_res.nAnyPattern)-50*rhythm_res.ratioNormal45_100_c1-800*(rhythm_res.longestNormalSeq>45)+800*(rhythm_res.longestNormalSeq==0) +1*rhythm_res.Nectopic+10*av_res.nOtherRhythmBeats+0.75*rhythm_res.hrtrt+200*rhythm_res.ratioSlow50+200*rhythm_res.ratioFast100 + 2000*(rhythm_res.ratioFast120>0.29) + 1000*(rhythm_res.ratioSlow45>0.23) + 2000*(rhythm_res.ratioFast110>0.43)+1800*(rhythm_res.hrtrt>100)+1800*(rhythm_res.hrtrt<50)-5 * rhythm_res.perc_regular + 100*rhythm_res.ratioRegular1 +25*ws_res.N_seq_of_2_non1inArow + 350*ws_res.N_homo_rel - cc_res.perc_sc1*10 + 2000*(rhythm_res.ratioRegular10<0.46) - 2000*rhythm_res.ratioRegular10_PartDiff.^3 + 2000*(rhythm_res.nPattern_AD_in_Ns>5) - 800*(af_res.atrial_frequency>6) - 100*(av_res.isWPW_1>0.28) - 200*(av_res.P_amplitude2_1>0.038) - 1000*(av_res.P_amplitude2rel_1<0) + 1000*(isfinite(av_res.T_off_2) & av_res.T_off_2<190) + 1200*(combined_res.normalOrOther>=1000) - 300*(combined_res.afOrNoise<-45) + 3000*(combined_res.is_normal<20 | combined_res.is_normal==25);

	combined_res.normalOrAF_new=af_res.rr_irregularity+af_res.rr_irregularity2/100-av_res.P_amplitude4_1*10+combined_res.afOrNormal/100 + (ws_res.N_tachy_max_beats_in_a_row>5) -0.158*(af_res.mean_atrialHR<210)  + af_res.IrrEv/50 - 0.025*rhythm_res.stds_c1 + 00.005*rhythm_res.mean_mov_diff_c1 - 0.1*rhythm_res.n_hist - 0.075*av_res.nbeats_2 - 0.55*(ws_res.ecgLength>59);

	combined_res.normalOrNoise_new=10*qrs_res.dd+beat_res.amp_gini+beat_res.bci_gini*10+10*cc_res.ratioSCsUniqueBeforeCorrection-0.1*rhythm_res.majorel-4*(rhythm_res.longestNormalSeq>25)+5*rhythm_res.ratioFast120-5*rhythm_res.ratioRegular20  + 10*(af_res.pp_irregularity>2.6);

	combined_res.afOrOther_new=min(200,abs(75-af_res.rr_irregularity2)+200*av_res.P_amplitude4_1+10*(beat_res.bci_skewness<0)-20*(rhythm_res.nsamp<9000) - 5*sqrt(rhythm_res.NPa)+20*rhythm_res.Nectopic + 50*(rhythm_res.ratioRegular10_bestPart>=1)+ 20*rhythm_res.ratioPatternMax + 100*(rhythm_res.perc_premajure==0) + 50*(af_res.IrrEv<8) + 100*(combined_res.afOrNoise<-12));

	combined_res.otherOrNoise=-combined_res.afOrNoise + combined_res.normalOrNoise_new-100*ws_res.N_brady - 20*ws_res.N_tachy + ws_res.N_hetero_rel*100 - ws_res.ecgAmpMin*10 - ws_res.ecgLength - av_res.nOtherRhythmBeats + commonPattern_res.width_max*150 - commonPattern_res.BCI_min/10 - Pres.corr_max*100 - 500*isfinite(Pres.corr_mean).*(af_res.iqrPamp<0.09) + 1000*cc_res.ratioSCsUniqueBeforeCorrection - rhythm_res.ratioSlow45*200 - 10*rhythm_res.ratioPatternSum - 100*(rhythm_res.ratioNormal45_100_smooth_c1<0.15) - 200*(rhythm_res.ratioSlow50_c1>0.3);


    processedTimeStamp=now;
    
    
    
%     save(resultsFileName);
end

 
    
    cell_names='RecID';
	cell_values=recNr;
	if pars.add_commonPattern
		[commonPattern_res_names,commonPattern_res_values]=getNameAndValues(commonPattern_res,'commonPattern');
		cell_names=[cell_names;commonPattern_res_names];
		cell_values=[cell_values;commonPattern_res_values];
	end
	if pars.add_Pres
		[Pres_names,Pres_values]=getNameAndValues(Pres,'P');
		cell_names=[cell_names;Pres_names];
		cell_values=[cell_values;Pres_values];
		[QRSres_names,QRSres_values]=getNameAndValues(QRSres,'QRS');
		cell_names=[cell_names;QRSres_names];
		cell_values=[cell_values;QRSres_values];
	end

	if pars.add_qrs
		[qrs_res_names,qrs_res_values]=getNameAndValues(qrs_res,'qrs');
		cell_names=[cell_names;qrs_res_names];
		cell_values=[cell_values;qrs_res_values];
	end
	if pars.add_beat
		[beat_res_names,beat_res_values]=getNameAndValues(beat_res,'beat');
		cell_names=[cell_names;beat_res_names];
		cell_values=[cell_values;beat_res_values];
	end
	if pars.add_inv
		[inv_res_names,inv_res_values]=getNameAndValues(inv_res,'inv');
		cell_names=[cell_names;inv_res_names];
		cell_values=[cell_values;inv_res_values];
    end
	if pars.add_corr
		[cc_res_names,cc_res_values]=getNameAndValues(cc_res,'cc');
		cell_names=[cell_names;cc_res_names];
		cell_values=[cell_values;cc_res_values];
    end
	if pars.add_rhythm
		[rhythm_res_names,rhythm_res_values]=getNameAndValues(rhythm_res,'rhythm');
		cell_names=[cell_names;rhythm_res_names];
		cell_values=[cell_values;rhythm_res_values];
    end
	if pars.add_af
		[af_res_names,af_res_values]=getNameAndValues(af_res,'af');
		cell_names=[cell_names;af_res_names];
		cell_values=[cell_values;af_res_values];
    end
	if pars.add_av
		[av_res_names,av_res_values]=getNameAndValues(av_res,'av');
		cell_names=[cell_names;av_res_names];
		cell_values=[cell_values;av_res_values];
	end
	if pars.add_remav
		[remav_res_names,remav_res_values]=getNameAndValues(remav_res,'remav');
		cell_names=[cell_names;remav_res_names];
		cell_values=[cell_values;remav_res_values];
	end
	if pars.add_ws
		[ws_res_names,ws_res_values]=getNameAndValues(ws_res,'ws');
		cell_names=[cell_names;ws_res_names];
		cell_values=[cell_values;ws_res_values];
	end
	if pars.add_noise
		[noise_res_names,noise_res_values]=getNameAndValues(noise_res,'noise');
		cell_names=[cell_names;noise_res_names];
		cell_values=[cell_values;noise_res_values];
	end
	if pars.add_combined
		[combined_res_names,combined_res_values]=getNameAndValues(combined_res,'combined');
		cell_names=[cell_names;combined_res_names];
		cell_values=[cell_values;combined_res_values];
	end
	result=cell2dataset(cell_values','VarNames',cell_names');
	for i=1:length(pars.pars2ignore)
		result.(pars.pars2ignore{i})=[];
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
    result=cell2dataset(cell_values','VarNames',cell_names');
	for i=1:length(pars.pars2ignore)
		result.(pars.pars2ignore{i})=[];
    end
    result.RecID = [];
    result.commonPattern_BCI_ratioInDeCreases = [];
    export(result,'File',[recordName '.csv'],'Delimiter',',');
elseif ~isempty(model)
    %evaluation mode: return prediction for record based on given model
   
    %display(ds);
    result=predict(model,cell2dataset(cell_values','VarNames',cell_names'));
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

