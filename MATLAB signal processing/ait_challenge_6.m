function [result,dataPerBeat] = ait_challenge_2(recordName,pars,model)
%
% Sample entry for the 2017 PhysioNet/CinC Challenge.
%
% INPUTS:
% recordName: string specifying the record name to process
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


if nargin<2
    pars=get_pars(300);
end

if nargin<1
    recordName='D:\data\cinc2017\_raw\A00001';% N
end

classifyResult = 'N'; % default output normal rhythm

recNr=eval(recordName(end-4:end));

resultsFileName=[recordName,'.',mfilename]; % store results in a file with the name of the present function as the extension
if exist(resultsFileName) & 0
    fprintf(' ... loading results for signal "%s" ...\r',resultsFileName);
    load(resultsFileName,'-mat'); % supposed to yield all needed results
else
    fprintf(' ... (re)computing "%s" ...\r',resultsFileName);
    
    
    %% Load Signals
    [tm,ecg,fs,siginfo]=rdmat(recordName);
    ecgLength=tm(end)-tm(1);
   
    
    %% Remove spikes
    %ecg_filtered=spike_filter(ecg);
    % ecg=schmidt_spike_removal(ecg,fs);
    % subplot(211), plot(ecg)
    %ecg_filtered=spike_filter(ecg);
    
    % subplot(212), plot(ecg_filtered)
    
    
    
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
    classes=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
    cc_res.perc_sc1_95=length(find(classes>1))/length(classes)*100;
    
    classes2=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw2,pars.corrclass.ccmin2);
    cc_res.perc_sc1_98=length(find(classes2>1))/length(classes2)*100;
    
    % GSc 2017-06-11 get rid of any unstable sequences longer than 5 events
    n_different_in_a_row_min=[2:10];
    classes_blank=classes;
    s_95=diff(classes)~=0;
    s_is_1=classes==1;
    s_95(s_is_1(2:end))=0; % dont count transitions to 1 (mainclass)
    %    different_in_a_row_95_cumsum=cumsum(s_95).*s_95;
    I_end = find(diff(s_95)==-1)+1;
    I_start = find(diff(s_95)==1)+1;
        if s_95(1)
            I_start = [1 I_start]; % prepend 1 to start indices, assuming that the start of the first unstable sequence was lost
        end
        if s_95(end) == 1
            I_end = [I_end numel(s_95)]; % append length of s to end indices, assuming that the end of the last unstable sequence was lost
        end
        if all(s_95) % each class is different - -does lead to empty I_start and I_end
            I_start = 1;
            I_end = numel(s_95);
            classes_blank=nan(size(classes)); % make sure, all elements are set to nan
        end
    
    different_in_a_row_95 = I_end - I_start;
    if ~isempty(different_in_a_row_95)
%         for i=1:numel(different_in_a_row_95)
%             cur_seq=classes(I_start(i):I_end(i));
%             different_in_a_row_95_unique(1,i) =numel(unique(cur_seq));
%             different_in_a_row_95_unique_wo_1(1,i) = numel(unique(cur_seq))-sum(cur_seq~=1);
%             different_in_a_row_95_1_to_unique(1,i) = sum(cur_seq==1)/numel(unique(cur_seq));
%         end
%         different_in_a_row_95_unique_rel = different_in_a_row_95_unique./different_in_a_row_95;
        %        II=find(different_in_a_row_95>3 & different_in_a_row_95_unique_rel>0.75 & different_in_a_row_95_unique_wo_1>0 & different_in_a_row_95_1_to_unique<1); % more than 75% of events in sequence need to be uniqe
        II=find(different_in_a_row_95>=3); % simple but robust criterion
    else
        II=[];
    end
    % blank out noise sequences
    for i=1:numel(II)
        classes_blank(I_start(II(i)):I_end(II(i)))=nan;
    end
    if ~all(s_95) % set main class elements back to 1, except in an all different sequence (would lead to single 1s at the beginning or at the end
        classes_blank(classes==1)=1;
    end
    classes=classes_blank;
    cc_res.n_NaN_rel=sum(isnan(classes))/numel(classes);
    cc_res.n_NaN_seq=numel(II);
    cc_res.n_different_in_a_row_95_MAX=max(different_in_a_row_95); % maximum number of different classes in a row
    cc_res.n_different_in_a_row_95_MAX_rel=max(different_in_a_row_95)/numel(classes); % maximum number of different classes in a row relative 
    
    if 0 % GSc 2017-06-06 - remove noise sequence at the beginning
    for i=1:numel(n_different_in_a_row_min)
        n_different_in_a_row_95_min_i=n_different_in_a_row_min(i);
        var_name_i=['n_different_in_a_row_95_min_',int2str(n_different_in_a_row_95_min_i)];
        eval([var_name_i,'=sum(different_in_a_row_95 > n_different_in_a_row_95_min_i);']); % number of sequences with at least n_different_in_a_row_min
        cc_res.(var_name_i)=eval(var_name_i); % number of sequences with at least n_different_in_a_row_min
    end
    
    
    
        cc_res.Nnotdifferent_sc_95=min([find(diff(classes)==0),round(numel(classes)*2/3)]); % keep at least last third of events
        cc_res.Nnotdifferent_sc_98=min([find(diff(classes2)==0),round(numel(classes2)*2/3)]); % keep at least last third of events
        cc_res.Nnotdifferent_sc_min = min(cc_res.Nnotdifferent_sc_95,cc_res.Nnotdifferent_sc_98);
        if cc_res.Nnotdifferent_sc_min > 1 && 0 % get rid of initial sequence with all different classes
            QRS2=QRS2(cc_res.Nnotdifferent_sc_min:end);
            amps=amps(cc_res.Nnotdifferent_sc_min:end);
            qrs_widths=qrs_widths(cc_res.Nnotdifferent_sc_min:end);
            
            classes=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
            cc_res.perc_sc1_95=length(find(classes>1))/length(classes)*100;
            
            classes2=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw2,pars.corrclass.ccmin2);
            cc_res.perc_sc1_98=length(find(classes2>1))/length(classes2)*100;
        end
    end
    
    if ~all(isnan(classes))
        %% Get Averaged Beat
        [av_res,avbeats]=avbeat_cinc2017(ecg,QRS2,classes,fs,pars);
        
        % GSc 2017-06-15 - measure QT level - "qt" should actually be "st"
        Isc=find(avbeats.SC==1);
        sc_seq=avbeats.seq{Isc};
        qt_inds=[fs*0.05:fs*0.10];
        pq_inds=[-fs*0.05:-fs*0.025];
        I_qt_inds=-avbeats.window{Isc}(1)+qt_inds;
        I_pq_inds=-avbeats.window{Isc}(1)+pq_inds;
        if max(I_qt_inds)<=length(sc_seq) & min(I_qt_inds)>0
            av_res.qt_level=mean(sc_seq());
        else
            av_res.qt_level=nan;
        end
        if max(I_pq_inds)<=length(sc_seq) & min(I_pq_inds)>0
            av_res.pq_level=mean(sc_seq());
        else
            av_res.pq_level=nan;
        end
        
        
        %% Rhythm Classification
        [types,rhythm_res]=rhythmclass_cinc2017(ecg,QRS2,classes,amps,qrs_widths,fs,pars,avbeats);
        
        
        %% Save Averaged Beats
        % GSc 2017-05-21 - no longer needed is part of the res file now
        %    save([recordName,'_avbeats.mat'],'avbeats','-mat')
        
        
        %% Remove Averaged Beat
        atrial_ecg=removeaverage_cinc2017(ecg,QRS2,classes,avbeats,fs,pars);
        
        %% Detect AF
        af_res=detectaf_cinc2017(ecg,QRS2,classes,types,atrial_ecg,avbeats,fs,pars);
        
        %% Detect noise
        noise_res=isnoise_cinc2017(ecg,QRS,QRS2,classes,...
            avbeats,types,amps,qrs_widths,atrial_ecg,fs,pars);
        
        %% AF-Classficiation according to source template
        QRS2use=QRS;
        % QRS2use=QRS2;
        if length(QRS2use)>=6
            RR=diff(QRS2use')/fs;
            [OriginCount,IrrEv,PACEv,AFEv] = comput_AFEv(RR);
            af_res.AFEv = AFEv;
            af_res.OriginCount = OriginCount;
            af_res.IrrEv = IrrEv;
            af_res.PACEv = PACEv;
            
        else
            af_res.AFEv=NaN;
            af_res.OriginCount = NaN;
            af_res.IrrEv = NaN;
            af_res.PACEv = NaN;
        end
        
        if af_res.P_amplitude<=0.01 || isnan(af_res.P_amplitude)
            af_res.pWaveAbsence=1;
        elseif af_res.P_amplitude>0.01
            af_res.pWaveAbsence=0;
        else
            af_res.pWaveAbsence=-1;
        end
        if af_res.P_amplitude2<=0.01 || isnan(af_res.P_amplitude)
            af_res.pWaveAbsence2=1;
        elseif af_res.P_amplitude2>0.01
            af_res.pWaveAbsence2=0;
        else
            af_res.pWaveAbsence2=-1;
        end
    else
        types=[];
        avbeats=[];
    end
        
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
        
        result=[];
        
        processedTimeStamp=now;
        save(resultsFileName);
    
end


%training mode: return dataset for record
if nargin<3
    
else
    %evaluation mode: return prediction for record based on given model
    ds=double(cell2dataset(cell_data,'VarNames',varNames));
    %TODO: fix this
    load('vars2use.mat')
    
    ds=ds(:,find(vars2use));
    %display(ds);
    result=predict(model,ds);
end



