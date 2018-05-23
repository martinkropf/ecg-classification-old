function [QRS2,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg,fs,pars)

dmin=pars.detectevents.dmin; 
nmin=pars.detectevents.nmin/60*length(ecg)/fs;
nmax=pars.detectevents.nmax/60*length(ecg)/fs;
b=pars.detectevents.b;
a=pars.detectevents.a;
blank_func=pars.detectevents.blank_func;

%% Detect events using det_pick
bandpass_seq = filtfilt(b,a, ecg);
aseqd=abs(diff(bandpass_seq));  
[QRS2,dd, qrs_range, n_not_sel,iqr_qrs,res_pick]=...
	arcs_detpick_cinc2017(aseqd,blank_func,dmin,nmin,nmax,[],[],[],pars.detectevents.doGini);

%% Check if Quality is low. If so, try with higher bandpass window 20-30 Hz
if dd>-0.1 && qrs_range>2 && iqr_qrs > 0.01 && pars.detectevents.allow2ndRun
	% get current RR-irregularity
	bcis=diff(QRS2)/fs;
	rrs=60./bcis;
	median_rr=median(rrs);
	rr_irregularity=length(find(abs(rrs-median_rr)>10))/length(rrs)*100;
	
	% re-detect QRS with other filter
	
	bandpass_seq2=filtfilt(pars.detectevents.b2,pars.detectevents.a2,ecg); 
	aseqd2=abs(diff(bandpass_seq2));
	[QRS3,dd3, qrs_range3, n_not_sel3,iqr_qrs3,res_pick]=...
		arcs_detpick_cinc2017(aseqd2,blank_func,dmin,nmin,nmax,[],[],[],pars.detectevents.doGini);
	% Calc new RR-irregularity
	bcis=diff(QRS3)/fs;
	rrs=60./bcis;
	median_rr=median(rrs);
	rr_irregularity3=length(find(abs(rrs-median_rr)>10))/length(rrs)*100;
	
	% Choose result with lower irregularity
	if rr_irregularity3<rr_irregularity
		QRS2=QRS3;
		dd=dd3;
		qrs_range=qrs_range3;
		n_not_sel=n_not_sel3;
		iqr_qrs=iqr_qrs3;
	end
    secondRun=1;
else
    secondRun=0;
end

%% Save results to qrs_res
qrs_res=res_pick;
qrs_res.secondRun=secondRun;
qrs_res.dd=dd;
qrs_res.n_not_sel=n_not_sel;
qrs_res.iqr_qrs=iqr_qrs;
qrs_res.qrs_range=qrs_range;


%% Remove QRS at the very beginning and ending
QRS2(QRS2<fs*pars.detectevents.distBorderMin)=[];
QRS2(QRS2>length(ecg)-pars.detectevents.distBorderMin*fs)=[];

[QRS2,amps,qrs_widths,baselines,drifts,irregularities]=setFP(QRS2,ecg,fs,pars);

qrs_res.baseline_mean=mean(baselines);
qrs_res.baseline_std=std(baselines);
qrs_res.drift_mean=mean(drifts);
qrs_res.drift_std=std(drifts);
qrs_res.nIrregularities=length(irregularities==1);
qrs_res.nIrregularities=length(irregularities==0.5);
qrs_res.nProblems=length(~isfinite(irregularities));
% %% Set QRS to fiductial point FP and calc amps
% fpw=pars.detectevents.fpw;
% amps=zeros(length(QRS2),1);
% qrs_widths=zeros(length(QRS2),1);
% for i=1:length(QRS2)
% 	
% 	from=max(1,QRS2(i)+fpw(1)*fs);
% 	to=min(length(ecg),QRS2(i)+fpw(2)*fs);
% 	cur_seq=ecg(from:to);
% 	[~,FP]=max(abs(cur_seq-mean(cur_seq))); % mit Offsetkorrektur
% 	if FP==length(cur_seq) || FP==1				% kein echtes max
% 		[~,FP]=max(cur_seq);				% Versuch, einfach das max zu berechnen
% 		if FP==length(cur_seq) || FP==1				% wieder nichts
% 			[~,FP]=min(cur_seq);				% Versuch, einfach das min zu berechnen
% 		end
% 	end
% 	cur_seq=cur_seq-mean(cur_seq);
% 	QRS2(i)=FP+from-1;
% 	
% % 	% Methode 1 - amp und width ganz schnell berechnen
% % 	amps(i)=max(cur_seq)-min(cur_seq);
% % 	last_zeroCross_prior_FP=find(diff(cur_seq(1:FP)>0)~=0,1,'last');
% % 	first_zeroCross_post_FP=FP+find(diff(cur_seq(FP:end)>0)~=0,1,'first');
% % 	if isempty(last_zeroCross_prior_FP), last_zeroCross_prior_FP=1; end
% % 	if isempty(first_zeroCross_post_FP), first_zeroCross_post_FP=length(cur_seq); end
% % 	qrs_widths(i)=(first_zeroCross_post_FP-last_zeroCross_prior_FP)/fs;
% 	
% 	% Methode 2 - Beginn und Ende von QRS mit neuer Methode bestimmen
% 	% funktioniert bei schoenen sigs ja gut, bei schlechten aber gar nicht!
% 	[b,a]=butter(2,[4,25]*2/fs,'bandpass');
% 	cur_ecg= filtfilt(b,a, ecg);
% 
% 	from2=max(1,QRS2(i)-0.3*fs);
% 	to2=min(length(ecg),QRS2(i)+0.3*fs);
% 	cur_ecg=cur_ecg(from2:to2);
% 	FP=FP+from-from2;
% 	last_point_before_QRS=getQRSendPoint(cur_ecg(1:FP),0.03*fs,-0.005,1/20);
% 	samp_right_end=min(length(cur_ecg),FP+0.3*fs);
% 	first_point_after_QRS=getQRSendPoint(cur_ecg(samp_right_end:-1:FP),0.03*fs,-0.005,1/20);
% 	first_point_after_QRS=samp_right_end-first_point_after_QRS;
% 	amps(i)=range(cur_ecg(last_point_before_QRS:first_point_after_QRS));
% 	qrs_widths(i)=(first_point_after_QRS-last_point_before_QRS)/fs;
% 	
% % 	fh=figure; 
% % 	plot(cur_ecg); 
% % 	line([first_point_after_QRS,last_point_before_QRS],cur_ecg([first_point_after_QRS,last_point_before_QRS]),'LineStyle','none','Marker','*')
% % 	keyboard;
% % 	delete(fh);
% end
