function af_res=detectaf_cinc2017(ecg,QRS,QRS_cinc,classes,types,atrial_ecg_org,atrial_ecg_org2,avbeats,fs,pars)
PLOT_FIGURE=0;
nevs=length(QRS);

spec_order=pars.detectaf.spec_order;
winfunc=pars.detectaf.winfunc;
winpar=pars.detectaf.winpar;
spec_methode=pars.detectaf.spec_methode;
av_pwave_window=pars.detectaf.av_pwave_window;
av_twave_window=pars.detectaf.av_twave_window;
fr=pars.detectaf.fr;

%% ---- Feature 1 - Unregelmaessigkeit der RR-Intervalle
bcis=diff(QRS)/fs;
bcis=bcis(find(isfinite(classes(1:end-1))));
b2bHRs=60./bcis;
median_HR=median(b2bHRs);
af_res.rr_irregularity=iqr(b2bHRs)/median_HR;
af_res.rr_irregularity2=length(find(abs(b2bHRs-median_HR)>10))/length(b2bHRs)*100;

%% Suche nach einem schoenen Signalbereich
if pars.detectaf.findOptimalWindow
	af_res.nice_found=0;
	if length(classes)>5
		% perfekte sequenz mit nur SC1-beats, kleiner atr. amp  und konstanter HR suchen
		high_amplitude_samps=find(abs(atrial_ecg_org)>pars.detectaf.atrial_ecg_amp_max);
		[QRS_test,order]=sort([QRS,high_amplitude_samps']);
		classes=[classes,ones(size(high_amplitude_samps'))*-1];
		classes=classes(order);
		cl_test=classes;
		irreg_bci=find(abs(bcis-median(bcis))>pars.detectaf.nice_bci_diff_max);
		if ~isempty(irreg_bci)
			cl_test(irreg_bci)=-1;
			cl_test(irreg_bci+1)=-1;
		end
		cl_test=[0,1,cl_test,1,0];
		nice_start=find(cl_test(2:end-1)==1 & diff(cl_test(1:end-1))~=0)+1;
		nice_stop=find(cl_test(2:end-1)==1 & diff(cl_test(2:end))~=0);
		nice_lengths=nice_stop-nice_start;
		[longest_nice_dur,longest_nice_pos]=max(nice_lengths);
		if longest_nice_dur>=pars.detectaf.nice_dur_min
			af_res.nice_found=2;
			best_start=max(1,nice_start(longest_nice_pos)-2);
			best_stop=min(length(classes),nice_stop(longest_nice_pos)-2);
		else
			% keine perfekte sequenz genfunden: nur nach "nice" sequenz mit
			% lauter SC1-beats suchen
			cl_test=[0,1,classes,1,0];
			nice_start=find(cl_test(2:end-1)==1 & diff(cl_test(1:end-1))~=0)+1;
			nice_stop=find(cl_test(2:end-1)==1 & diff(cl_test(2:end))~=0)+1;
			nice_lengths=nice_stop-nice_start;
			[longest_nice_dur,longest_nice_pos]=max(nice_lengths);
			if longest_nice_dur>=pars.detectaf.nice_dur_min
				af_res.nice_found=1;
				best_start=max(1,nice_start(longest_nice_pos)-2);
				best_stop=min(length(classes),nice_stop(longest_nice_pos)-2);
			end
		end
	end

	if ~af_res.nice_found
		from_samp=1;
		to_samp=length(atrial_ecg_org);
	else
		from_samp=max(1,QRS_test(best_start)-0.3*fs);
		to_samp=min(length(atrial_ecg_org),QRS_test(best_stop)+0.6*fs);
	end
else
	from_samp=1;
	to_samp=length(atrial_ecg_org);
end
if PLOT_FIGURE
	fh=figure('Position',[20,20,1000,1000]); 
	subplot(3,1,1);
	plot(atrial_ecg_org); hold on; plot(ecg);
	xlim=get(gca,'XLim');
end

atrial_ecg_org=atrial_ecg_org(from_samp:to_samp);

if PLOT_FIGURE
	subplot(3,1,2);
	plot(from_samp:to_samp,atrial_ecg_org);
	set(gca,'YLim',[-0.5,0.5],'xlim',xlim);
end
	
%% --- Feature 2 - Frequenzbereich: Energie im Band zw. 5 u 10 Hz
atrial_ecg=atrial_ecg_org;
atrial_ecg(abs(atrial_ecg)>iqr(atrial_ecg)*20)=0; % remove spikes / high amplitude regions
atrial_ecg=filtfilt(pars.detectaf.b,pars.detectaf.a,atrial_ecg);
N=length(atrial_ecg);
win_func=get_win_func(length(atrial_ecg),winfunc,winpar);
[Pxx,f]=calc_spec(atrial_ecg,spec_methode,win_func,spec_order,N,fs);
stft(1:length(Pxx))=zeros(length(Pxx),1);
stft(1:length(Pxx))=Pxx;
[spec_max,f_max_ind]=max(stft);
af_res.atrial_frequency=f(f_max_ind);

%% alternative Methode: Sig-Amp in unterschiedlichen Fr-Baendern
%  GSC 2017-06-04 - check code - FFT would be faster and more general?
for i=1:length(fr)-1
	fseq=filtfilt(pars.detectaf.bf{i},pars.detectaf.af{i},atrial_ecg);
	p_freq(i)=std(fseq);
	eval(['af_res.p_af_freq_',int2str(i),'=p_freq(i);']);
	p_freq_rel(i)=p_freq(i)/p_freq(1);
	eval(['af_res.p_af_freq_rel_',int2str(i),'=p_freq_rel(i);']);
end


%% ---------- Feature 4 - Anzahl an Atrialen Peaks nach Filterung
atrial_ecg2=atrial_ecg_org;
atrial_ecg2(abs(atrial_ecg2)>iqr(atrial_ecg2)*20)=0; % remove spikes / high amplitude regions
atrial_ecg2=filtfilt(pars.detectaf.b2,pars.detectaf.a2,atrial_ecg2);
peak_res=analyze_peaks(atrial_ecg2,pars.detectaf.minPeakDistance1*fs,...
		pars.detectaf.peaksQRSblankInt*fs,pars.detectaf.addPfromAV,...
		pars.detectaf.PdoubleInt*fs,QRS-from_samp+1,avbeats,median_HR,fs);
fieldNames=fieldnames(peak_res);
for i=1:length(fieldNames)
	af_res.([fieldNames{i},'1'])=peak_res.(fieldNames{i});
end

peak_res=analyze_peaks(atrial_ecg2,pars.detectaf.minPeakDistance2*fs,...
		pars.detectaf.peaksQRSblankInt*fs,pars.detectaf.addPfromAV,...
		pars.detectaf.PdoubleInt*fs,QRS-from_samp+1,avbeats,median_HR,fs);
fieldNames=fieldnames(peak_res);
for i=1:length(fieldNames)
	af_res.([fieldNames{i},'1'])=peak_res.(fieldNames{i});
end


%% noch einmal aber jetzt ohne davor QRS zu blanken
atrial_ecg2=atrial_ecg_org2;
atrial_ecg2(abs(atrial_ecg2)>iqr(atrial_ecg2)*20)=0; % remove spikes / high amplitude regions
atrial_ecg2=filtfilt(pars.detectaf.b2,pars.detectaf.a2,atrial_ecg2);
peak_res=analyze_peaks(atrial_ecg2,pars.detectaf.minPeakDistance1*fs,...
		0,0,pars.detectaf.PdoubleInt*fs,QRS-from_samp+1,avbeats,median_HR,fs);
fieldNames=fieldnames(peak_res);
for i=1:length(fieldNames)
	af_res.([fieldNames{i},''])=peak_res.(fieldNames{i});
end

peak_res=analyze_peaks(atrial_ecg2,pars.detectaf.minPeakDistance2*fs,...
		pars.detectaf.peaksQRSblankInt*fs,pars.detectaf.addPfromAV,...
		pars.detectaf.PdoubleInt*fs,QRS-from_samp+1,avbeats,median_HR,fs);
fieldNames=fieldnames(peak_res);
for i=1:length(fieldNames)
	af_res.([fieldNames{i},'1'])=peak_res.(fieldNames{i});
end

if PLOT_FIGURE
	hold on
	plot(from_samp:to_samp,atrial_ecg2);
	line(from_samp+atrial_peak_inds,atrial_peak_amps,'LineStyle','none','Marker','*');
	line(from_samp+P_samps,P_amps,'LineStyle','None','Color','r','Marker','*');
	% set(gca,'YLim',[-0.5,0.5],'xlim',xlim);
	af_res
	
	subplot(3,1,3);
	plot(from_samp:to_samp,atrial_ecg2);
	line(from_samp+atrial_peak_inds,atrial_peak_amps,'LineStyle','none','Marker','*');
	line(from_samp+P_samps,P_amps,'LineStyle','None','Color','r','Marker','*');
	line(QRS,zeros(size(QRS)),'Marker','*','LineStyle','none','Color','g');
	if isfinite(P_from_av)
		line(QRS+P_from_av,zeros(size(QRS)),'Marker','o','LineStyle','none','Color','m');
	end
	set(gca,'YLim',[-0.5,0.5],'xlim',[from_samp, from_samp+1000]);
	
	keyboard;
	delete(fh);
end

%% AF-Classficiation according to CinC source code template
QRS2use=QRS_cinc;
% QRS2use=QRS;
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


function peak_res=analyze_peaks(atrial_ecg2,minPeakDistance,peaksQRSblankInt,...
	addPfromAV,PdoubleInt,QRS_in_seq,avbeats,median_HR,fs)
[P_amps,P_samps]=findpeaks(atrial_ecg2,'MinPeakDistance',minPeakDistance);

QRS_in_seq=QRS_in_seq(QRS_in_seq>0);
if peaksQRSblankInt>0
	% remove peaks within QRS
	QRS_in_seq=QRS_in_seq(QRS_in_seq>0 & QRS_in_seq<=length(atrial_ecg2));
	P_samps(end+1:end+length(QRS_in_seq))=QRS_in_seq;
	P_amps(end+1:end+length(QRS_in_seq))=atrial_ecg2(QRS_in_seq);
	[P_samps,order]=sort(P_samps);
	P_amps=P_amps(order);
	inds_double=find(diff(P_samps)<peaksQRSblankInt);
	inds_double=[inds_double;inds_double+1];
	inds_double=sort(inds_double);
	inds_double(diff(inds_double)==0)=[];
	inds_QRS=find(ismember(P_samps(1:end-1),QRS_in_seq));
	inds_double=[inds_double;inds_QRS];
	P_samps(inds_double)=[];
	P_amps(inds_double)=[];
end

% add all P waves as calculated from av-beat
if addPfromAV
	if isfield(avbeats,'window') && ~isempty(avbeats.window{1})
		P_from_av=round(avbeats.window{1}(1)+(avbeats.P_off(1)+avbeats.P_on(1))/2);
		if isfinite(P_from_av)
			Ps_from_av=QRS_in_seq+P_from_av;
			Ps_from_av=Ps_from_av(Ps_from_av>0 & Ps_from_av<=length(atrial_ecg2));
			P_samps(end+1:end+length(Ps_from_av))=Ps_from_av;
			P_amps(end+1:end+length(Ps_from_av))=atrial_ecg2(Ps_from_av);
			[P_samps,order]=sort(P_samps);
			P_amps=P_amps(order);
			inds_double=find(diff(P_samps)<PdoubleInt);
			inds_double=[inds_double;inds_double+1];
			inds_double=sort(inds_double);
			inds_double(diff(inds_double)==0)=[];
			inds_P=find(ismember(P_samps(1:end-1),Ps_from_av));
			inds_double=setdiff(inds_double,inds_P);
			P_samps(inds_double)=[];
			P_amps(inds_double)=[];
		end
	end
	inds_double=find(diff(P_samps)==0);
	P_samps(inds_double)=[];
	P_amps(inds_double)=[];
end

% calculate positiona and amp of 
% a) first peak after each QRS
% b) max peak between each 2 QRS
firstPeakDists=zeros(size(QRS_in_seq));
firstPeakAmps=zeros(size(QRS_in_seq));
maxPeakDists=zeros(length(QRS_in_seq)-1,1);
maxPeakAmps=zeros(length(QRS_in_seq)-1,1);
for i=1:length(QRS_in_seq)
	cur_QRS=QRS_in_seq(i);
	firstPeak=P_samps(find(P_samps>cur_QRS,1,'First'));
	if ~isempty(firstPeak)
		firstPeakDists(i)=firstPeak-cur_QRS;
		firstPeakAmps(i)=atrial_ecg2(firstPeak);
	else
		firstPeakDists(i)=NaN;
		firstPeakAmps(i)=NaN;
	end
	if i<length(QRS_in_seq)
		[maxPeakAmps(i),maxPeakDists(i)]=max(atrial_ecg2(cur_QRS:QRS_in_seq(i+1)));
	end
end
firstPeakDists=firstPeakDists(isfinite(firstPeakDists));
firstPeakAmps=firstPeakAmps(isfinite(firstPeakAmps));

pattern_res=findCommonPatterns(firstPeakDists);
peak_res.nFirstPeakDistExtrema_rel=pattern_res.nExtrema_rel;
peak_res.firstPeakDist_ratioInDeCreases=pattern_res.ratioInDeCreases;
peak_res.firstPeakDist_medianMaxDist=pattern_res.medianMaxDist;
peak_res.firstPeakDist_iqrMaxDist=pattern_res.iqrMaxDist;

pattern_res=findCommonPatterns(firstPeakAmps);
peak_res.nFirstPeakAmpExtrema_rel=pattern_res.nExtrema_rel;
peak_res.firstPeakAmp_ratioInDeCreases=pattern_res.ratioInDeCreases;
peak_res.firstPeakAmp_medianMaxDist=pattern_res.medianMaxDist;
peak_res.firstPeakAmp_iqrMaxDist=pattern_res.iqrMaxDist;

pattern_res=findCommonPatterns(maxPeakDists);
peak_res.nMaxPeakDistExtrema_rel=pattern_res.nExtrema_rel;
peak_res.maxPeakDist_ratioInDeCreases=pattern_res.ratioInDeCreases;
peak_res.maxPeakDist_medianMaxDist=pattern_res.medianMaxDist;
peak_res.maxPeakDist_iqrMaxDist=pattern_res.iqrMaxDist;

pattern_res=findCommonPatterns(maxPeakAmps);
peak_res.nMaxPeakAmpExtrema_rel=pattern_res.nExtrema_rel;
peak_res.maxPeakAmp_ratioInDeCreases=pattern_res.ratioInDeCreases;
peak_res.maxPeakAmp_medianMaxDist=pattern_res.medianMaxDist;
peak_res.maxPeakAmp_iqrMaxDist=pattern_res.iqrMaxDist;

peak_res.medianPamp=median(P_amps);
peak_res.iqrPamp=iqr(P_amps);

pcis=diff(P_samps)/fs;
atrial_b2bhrs=60./pcis;
peak_res.median_atrialHR=median(atrial_b2bhrs);
peak_res.iqr_atrialHR=iqr(atrial_b2bhrs);
peak_res.median_atrialHR_ratio_HR=peak_res.median_atrialHR/median_HR;
peak_res.distMedian2multipleHR=abs(peak_res.median_atrialHR_ratio_HR-round(peak_res.median_atrialHR_ratio_HR));
peak_res.mean_atrialHR=mean(atrial_b2bhrs);
peak_res.mean_atrialHR_ratio_HR=peak_res.mean_atrialHR/median_HR;
peak_res.distMean2multipleRR=abs(peak_res.mean_atrialHR_ratio_HR-round(peak_res.mean_atrialHR_ratio_HR));
peak_res.g=length(find(abs(atrial_b2bhrs-peak_res.median_atrialHR)<50))/length(atrial_b2bhrs);

peak_res.pp_irregularity=iqr(atrial_b2bhrs)/peak_res.median_atrialHR;
peak_res.pp_irregularity2=length(find(abs(atrial_b2bhrs-peak_res.median_atrialHR)>10))/length(atrial_b2bhrs)*100;
