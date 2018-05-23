function [result,dataPerBeat] = ait_challenge_9(recordName,pars,model,recompute)
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
if nargin<3
    model=[];
end
if nargin<2 || isempty(pars)
    pars=get_pars(300);
end

if nargin<1
    [data_dir,signal_dir]=getLocalProperties();
    recordName=fullfile(signal_dir,'A00001');	% N
end
resultsFileName=[recordName,'.',mfilename,'.',pars.version]; % store results in a file with the name of the present function and the versioon as the extension
%resultsFileName=[recordName,'_',int2str(i),'.',mfilename,'.',pars.version]; % store results in a file with the name of the present function and the versioon as the extension

if ~recompute && exist(resultsFileName,'file')
    fprintf(' ... loading results for signal "%s" ...\r',resultsFileName);
    load(resultsFileName,'-mat'); % supposed to yield all needed results
else
    fprintf(' ... (re)computing "%s" ...\r',resultsFileName);
    
    
    %% Load Signals
    [tm,ecg,fs,siginfo]=rdmat(recordName);

    %% Suppress detection in the initial part of signal (often transients)
    if isfield(pars,'blankSecsAtStart') && ~isempty(pars.blankSecsAtStart) % remove first part of signal - keine Verbesserung (noise wird schlechter)...
        detectOffset=pars.blankSecsAtStart*fs;
    else
        detectOffset=0*fs;
    end

    seqTab=table;
    detectionTypeList=table;
    seqTab.binNumber=0; % number of Bin
    seqTab.binName=' '; % name of bin
    seqTab.startSample=1; % start sample
    seqTab.endSample=size(ecg,1); % end sample
    result=dataset;
    dataPerBeat=dataset;
    % generate seqence table
    if isfield(pars,'binLength') && ~isempty(pars.binLength)
        i=1;
        start_sample=1+detectOffset;
%        end_sample=min(size(ecg,1),pars.binLength*fs);
        end_sample=min(size(ecg,1),start_sample + pars.binLength*fs);
        while start_sample < size(ecg,1)
            if end_sample - start_sample < fs*5 % sequence must have a minimum length
                break;
            end
            [result_seq, dataPerBeat_seq, avbeats_seq, detectionTypeList_seq, processedTimeStamp] = ait_challenge_9_core(recordName,pars,model,recompute,ecg(start_sample:end_sample),fs);
            seqTab=[seqTab;{i,int2str(i),start_sample,end_sample}];

            result_seq.Bin=i;
            result=[result;result_seq];
            dataPerBeat_seq.Bin(:,1)=i;
            dataPerBeat_seq.QRS=dataPerBeat_seq.QRS + start_sample-1; % correct for offset so that beat FP is consistant
            dataPerBeat=[dataPerBeat;dataPerBeat_seq];
            avbeats(i)=avbeats_seq;
            detectionTypeList_seq.sample=detectionTypeList_seq.sample + start_sample-1; % correct for offset so that beat FP is consistant
            detectionTypeList_seq.beat=detectionTypeList_seq.beat + size(dataPerBeat,1); % correct for offset so that beat index is consistant
            detectionTypeList=[detectionTypeList;detectionTypeList_seq]; % correct for offset so that beat index is consistant

            i = i + 1;
%            start_sample=(i-1)*pars.binLength*fs+1;
%            end_sample=min(size(ecg,1),i*pars.binLength*fs);
            start_sample=end_sample + 1;
            end_sample=min(size(ecg,1),start_sample + pars.binLength*fs);
        end
    end
    save(resultsFileName, 'seqTab', 'result', 'dataPerBeat', 'avbeats', 'detectionTypeList', 'pars', 'processedTimeStamp');
end
end


function [result, dataPerBeat, avbeats, detectionTypeList, processedTimeStamp] = ait_challenge_9_core(recordName,pars,model,recompute,ecg,fs)

classifyResult = 'N'; % default output normal rhythm
eventTab=table; % intitialise
recNr=eval(recordName(end-4:end));
fs=pars.fs;

%% Load Signals
%    [tm,ecg,fs,siginfo]=rdmat(recordName);
nSamples=size(ecg,1); % number of samples
ws_res.ecgLength=nSamples/fs; % assigned to the work space sourceStructure
ws_res.ecgAmpMax=max(ecg);
ws_res.ecgAmpMin=min(ecg);
ws_res.ecgAmpRange=range(ecg);


%% Remove spikes
%ecg_filtered=spike_filter(ecg);
% ecg=schmidt_spike_removal(ecg,fs);
% subplot(211), plot(ecg)
%ecg_filtered=spike_filter(ecg);

% subplot(212), plot(ecg_filtered)

%% QRS Detection default
[QRS1, sign, en_thres] = qrs_detect2(ecg',0.25,0.6,fs);
% QRS1=QRS1+detectOffset;


%% Flip signal in case of lead inversion


%% Suppress detection in the initial part of signal (often transients)
detectOffset=pars.blankSecsAtStart*fs;

%% QRS Detection AIT
[QRS2a,amps,qrs_widths,qrs_res,detectionTypeList]=detectevents_cinc2017(ecg,fs,pars);
% QRS2a=QRS2a+detectOffset;

%% Flip singal in case of lead inversion
[isInverted, doInversion, inv_res]=checkForLeadInversion(ecg,QRS2a,fs,sign,pars);
if doInversion
    ecg=-ecg;
    [QRS2a,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg,fs,pars);
    inversionDone=1;
else
    inversionDone=0;
end


%% Falls die AIT-QRS-Det viel schlechter ist als jene vom CinC Sample Code: Sample Code nehmen
if isfield(pars,'suppressNonAITqrsDetection') && pars.suppressNonAITqrsDetection == 1 % Gsc 2017-07-02, suppress this if corresponding parameter is available and 1
else
    rrs_AIT=60./(diff(QRS2a)/fs);
    AIT_rr_irregularity2=length(find(abs(rrs_AIT-median(rrs_AIT))>10))/length(rrs_AIT)*100;
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
eventTab.classes1(:,1)=classes1';

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
eventTab.classes2(:,1)=classes2';
eventTab.QRS3=QRS3';
eventTab.classes3(:,1)=classes3';


%% Re-arrange correlation classification and calculate parameters with refined QRS complexes
[classes,beatTemplates,cc_res]=corrclass_cinc2017_results(QRS3,classes3,beatTemplates3);

eventTab.isExcess=zeros(size(eventTab(:,1)));
excessEvents = detectionTypeList.beat( ismember(detectionTypeList.type,'e') & ~isnan(detectionTypeList.beat) & detectionTypeList.beat<=length(classes));
if ~isempty(excessEvents)
    eventTab.isExcess(excessEvents)=1;
    % find and remove classes which comprise exclusively of excess beats
    tbl_e =crosstab(classes,eventTab.isExcess);
    tbl =crosstab(classes,ones(size(eventTab.isExcess)));
    excessClasses=find(tbl(:,1) == tbl_e(:,2));
    I_excess=ismember(classes,excessClasses);
    %         classes(I_excess)=nan;
    %         classes(I_excess)=0;
    classes(I_excess)=[];
    beatTemplates.count(ismember(beatTemplates.sclass,excessClasses))=0;
    beatTemplates=deleteZeroCountBeats(beatTemplates);
    eventTab(I_excess,:)=[];
    QRS3(I_excess)=[];
    amps(I_excess)=[];
    qrs_widths(I_excess)=[];
end
%     [classes_98,~,ws_res2]=corrclass_cinc2017(ecg,QRS3,fs,pars.corrclass.scw2,pars.corrclass.ccmin2,pars,providedClasses);
%     ws_res.perc_sc1_98=ws_res2.perc_sc1;
%     ws_res.perc_sc1_98_notNaN=ws_res2.perc_sc1_notNaN;

% GSc 2017-07-02 get rid of events from any class with less than a
% minimum number of elements (excluding excess detections)
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
ws_res.N_homo_max_beats_in_a_row_rel=max(str_length)/numel(classes); % maximum number of beats of the same class in a row
ws_res.N_homo_rel=sum(str_length)/numel(classes);

% GSc 2017-07-15 - analysis of inhomogeneous sequence, i.e. sequences where all subsequent elements belong to a different class
%    s=char('_'+classes);
%    hclasses=[0,classes,0];
d=diff(classes);
%    d=diff(hclasses); % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2
d=[diff(classes),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2
s=char(classes+'!');
%     s=char(hclasses+'!');
s(d==0)=' ';
[str,matches]=split(s);
str_length=cellfun(@length,str);
I_longEnough=str_length>=max(1,pars.n_min_for_a_row); % do not go below length of 1
ws_res.N_hetero_seq_of_more_than_min=sum(I_longEnough); % number of sequences
ws_res.N_hetero_classes_with_seq_of_more_than_min_max=max(cellfun(@nunique, str)); % unique classes
ws_res.N_hetero_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
ws_res.N_hetero_max_beats_in_a_row_rel=max(str_length)/numel(classes); % maximum number of beats of the same class in a row
ws_res.N_hetero_rel=sum(str_length)/numel(classes);
I_seq2nan=find(I_longEnough);
for i=1:numel(I_seq2nan) % set MC for elements of those sequences to NaN
    ss=strfind(s,str(I_seq2nan(i)));
    for j=1:numel(ss) % smae seqence could occure multiple times
        seq2beReplaced=classes(ss(j)+[1:str_length(I_seq2nan(i))]-1);
        skewOfSeq=skewness(seq2beReplaced);
        if sum(seq2beReplaced==mode(seq2beReplaced)) < length(seq2beReplaced)*2/5; % v27 - formerly 1/2 % request that sequence contains not more than 2/5 mainclass events - otherwise bigeminus would be nan'd
            classes(ss(j)+[1:str_length(I_seq2nan(i))]-1)=nan; % v26
            %                %                classes(ss(j)+[1:str_length(I_seq2nan(i))-1])=nan; % v25
%            disp([' heterogeneous sequence removed, abs(skewness) = ',abs(num2str(skewOfSeq))]);
        else
            %                disp([' heterogeneous sequence kept,    abs(skewness) = ',abs(num2str(skewOfSeq))]);
        end
    end
end

[classes,beatTemplates]=sortClasses(classes,beatTemplates); % sort classes according to their frequency of occurence

if pars.detectSpikesPosition==1 % moved to here from above
    if isfield(pars,'detectSpikesMethod') && pars.detectSpikesMethod > 0 % GSc 2017-07-16 - pragmatic detection and removal of isolated spikes, i.e a single different SC in between two events with the same SC
        isSpike=detectSpikes(classes,QRS3,pars,eventTab);
        eventTab.isSpike(isSpike==1,1)=1;
    end
    ws_res.n_spikes=sum(eventTab.isSpike > 0); % number of spikes in sequence
end

%    hclasses=[1,classes,1];
hclasses=[classes,1];
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

if sum(~isnan(classes))==1 % most likely artifact from incomplete removal - nan
    classes(~isnan(classes))=nan;
end
% set to nan all problematic events
I_2nan = eventTab.isSpike | eventTab.isLesserClass;
classes(I_2nan)=nan;
QRS3(I_2nan)=nan;
eventTab.BCI=[NaN;diff(QRS3)'];
eventTab.classes(:,1)=classes';
I_det_twice=eventTab.BCI==0;
if sum(I_det_twice) % attention - would lead to various complications donwn the line
    eventTab(I_det_twice,:)=[];
    QRS3(I_det_twice)=[];
    amps(I_det_twice)=[];
    qrs_widths(I_det_twice)=[];
    classes(I_det_twice)=[];
end



% GSc 2017-08-07 - use BCI estimate to reduce search area for p wave -
% no longer needed here - moved to inside avbeat_cinc2017
%    pars.BCI_est=mean(eventTab.BCI,'omitnan');

d=[diff(classes),0]; % append 0 to avoid increasing last fraction by 1 "121" would be counted as 3 differences instead of just 2
if pars.n_min_for_tachy>0 % GSc 2017-08-12 - use BCI and sequencing to detect temporary tachycardia
    s=char(repmat(' ',1,length(classes)));
    %        s(eventTab.BCI<fs*60/100 & ~isnan(eventTab.classes))='|'; % ignore nan
    %        s(eventTab.BCI<fs*60/100 & [d,nan]'==0)='|'; % ignore class changes
    s(eventTab.BCI<fs*60/100 & d'==0)='|'; % ignore class changes
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_tachy); % number of subsequent beats to define tachycardia
    ws_res.N_tachy=sum(I_longEnough); % number of tachy sequences
    ws_res.N_tachy_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_tachy_rel=sum(str_length)/numel(classes);
end

if pars.n_min_for_brady>0 % GSc 2017-08-12 - use BCI and sequencing to detect temporary bradycardia
    s=char(repmat(' ',1,length(classes)));
    s(eventTab.BCI>fs*60/40)='|';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=max(1,pars.n_min_for_brady); % number of subsequent beats to define bradycardia
    ws_res.N_brady=sum(I_longEnough); % number of brady sequences
    ws_res.N_brady_max_beats_in_a_row=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_brady_rel=sum(str_length)/numel(classes);
end

if pars.t2_nan_parameters > 0 % additional analysis of NaNs - sequencing based finally after all the detection and classification procedures
    s=char(repmat(' ',1,length(classes)));
    s(isnan(classes))='|';
    [str,matches]=split(s);
    str_length=cellfun(@length,str);
    I_longEnough=str_length>=1; % number of subsequent NaN to define NaN sequence
    ws_res.N_NaN_seq_t2=sum(I_longEnough); % number of NaN sequences
    ws_res.N_NaN_max_beats_in_a_row_t2=max(str_length); % maximum number of beats of the same class in a row
    ws_res.N_NaN_rel_t2=sum(str_length)/numel(classes);
    ws_res.perc_sc1_t2=length(find(classes>1))/length(classes)*100;
    ws_res.perc_sc1_notNaN_t2=length(find(classes(~isnan(classes))>1))/length(classes(~isnan(classes)))*100;
    
    % further NaN parameters
    classesWithoutNaNs=classes;
    classesWithoutNaNs(isnan(classesWithoutNaNs))=-1; % replace NaNs by -1 to prepare for tabulation
    CT_nonan=tabulate(classesWithoutNaNs);
    [CT_nonan,order] = sortrows(CT_nonan,2);
    CT_nonan=CT_nonan(fliplr(order),:);
    
    ws_res.n_NaN_rel_t2=sum(isnan(classes))/numel(classes);
    n_NaN_rank_t2=find(CT_nonan(:,1)==-1);
    if ~isempty(n_NaN_rank_t2)
        ws_res.n_NaN_rank_t2=n_NaN_rank_t2;
        ws_res.n_NaN_rel_2_mc_t2=CT_nonan(n_NaN_rank_t2,2)/max(CT_nonan(CT_nonan(:,1)~=-1,2));
        if isempty(ws_res.n_NaN_rel_2_mc_t2)
            ws_res.n_NaN_rel_2_mc_t2=nan;
        end
    else
        ws_res.n_NaN_rank_t2=nan;
        ws_res.n_NaN_rel_2_mc_t2=0;
    end
end


%% Get Averaged Beat
[av_res,avbeats]=avbeat_cinc2017(ecg,QRS3,classes,fs,pars,isInverted ~= inversionDone);

%% Rhythm Classification
[types,rhythm_res]=rhythmclass_cinc2017(ecg,QRS3,classes,amps,qrs_widths,fs,pars,avbeats);
eventTab.types=char(types');

%% Save Averaged Beats
% GSc 2017-05-21 - no longer needed is part of the res file now
%    save([recordName,'_avbeats.mat'],'avbeats','-mat')

%% Remove Averaged Beat
atrial_ecg=removeaverage_cinc2017(ecg,QRS3,classes,avbeats,fs,pars);

%% Detect AF
af_res=detectaf_cinc2017(ecg,QRS3,QRS1,classes,types,atrial_ecg,avbeats,fs,pars);

%% Detect noise
noise_res=isnoise_cinc2017(ecg,QRS1,QRS3,classes,...
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
        1/15 * rhythm_res.Nectopic + ...
        av_res.nOtherRhythmBeats;
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
dataPerBeat.RecID=ones(size(QRS3'))*recNr;
dataPerBeat.BeatID=[1:length(QRS3)]';
dataPerBeat.BCI=[NaN;diff(QRS3)'];
dataPerBeat.QRS=QRS3';
dataPerBeat.amp=amps;
dataPerBeat.width=qrs_widths;
dataPerBeat.corrClass95=classes';
%    dataPerBeat.corrClass98=classes_98';
dataPerBeat.rhythmClass=types';

if isfield(pars,'addStandardisedEventTimes') % GSc 2017-07-08 - add length normalised event times to calculate event moments later on
    I_nan=isnan(classes');
    dataPerBeat.tMCnorm(:,1)=nan;
    dataPerBeat.tMCnorm(~I_nan,1)=QRS3(~I_nan)'/nSamples;
    dataPerBeat.tNaNnorm(:,1)=nan;
    dataPerBeat.tNaNnorm(I_nan,1)=QRS3(I_nan)'/nSamples;
end

if isempty(model)
    % no model available => training mode: return dataset for record
    % 	%% Combine data per file in a struct
    % 	result=struct(...
    % 		'qrs_res',qrs_res,...
    % 		'ws_res',ws_res,...
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
    [inv_res_names,inv_res_values]=getNameAndValues(inv_res,'inv');
    
    cell_names=['RecID';qrs_res_names;cc_res_names;rhythm_res_names;af_res_names;av_res_names;noise_res_names;combined_res_names;ws_res_names;inv_res_names];
    cell_values=[recNr;qrs_res_values;cc_res_values;rhythm_res_values;af_res_values;av_res_values;noise_res_values;combined_res_values;ws_res_values;inv_res_values];
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

