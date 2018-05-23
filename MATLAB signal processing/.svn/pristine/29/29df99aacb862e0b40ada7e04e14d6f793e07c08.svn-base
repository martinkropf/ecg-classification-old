function [QRS,amps,widths,baselines,drifts,irregularities]=setFP(QRS,ecg,fs,pars)
% [QRS,amps,widths]=setFP(QRS,ecg,fs,fpw);
%
% DHa 2017-06-30
%
% Set QRS to fiductial point FP and calc amps

fpw=pars.detectevents.fpw;
b=pars.detectevents.filt_FP_b;
a=pars.detectevents.filt_FP_a;
amps=zeros(length(QRS),1);
widths=zeros(length(QRS),1);
baselines=zeros(length(QRS),1);
drifts=zeros(length(QRS),1);
irregularities=zeros(length(QRS),1);
for i=1:length(QRS)
	from=max(1,QRS(i)+fpw(1)*fs);
	to=min(length(ecg),QRS(i)+fpw(2)*fs);
	cur_seq=ecg(from:to);
	[~,FP]=max(abs(cur_seq-mean(cur_seq))); % mit Offsetkorrektur
	if FP==length(cur_seq) || FP==1				% kein echtes max
		[~,FP]=max(cur_seq);				% Versuch, einfach das max zu berechnen
		if FP==length(cur_seq) || FP==1				% wieder nichts
			[~,FP]=min(cur_seq);				% Versuch, einfach das min zu berechnen
		end
	end
	cur_seq=cur_seq-mean(cur_seq);
	QRS(i)=FP+from-1;
	
	% Beginn und Ende von QRS mit neuer Methode bestimmen
	% funktioniert bei schoenen sigs ja gut, bei schlechten aber gar nicht!
	cur_ecg= filtfilt(b,a, ecg);
	from2=max(1,QRS(i)-0.3*fs);
	to2=min(length(ecg),QRS(i)+0.3*fs);
	cur_ecg=cur_ecg(from2:to2);
	FP=FP+from-from2;
	last_point_before_QRS=getQRSendPoint(cur_ecg(1:FP),0.03*fs,-0.005,1/20);
	samp_right_end=min(length(cur_ecg),FP+0.3*fs);
	first_point_after_QRS=getQRSendPoint(cur_ecg(samp_right_end:-1:FP),0.03*fs,-0.005,1/20);
	first_point_after_QRS=samp_right_end-first_point_after_QRS;
	baselines(i)=mean(cur_ecg(last_point_before_QRS:first_point_after_QRS));
	drifts(i)=cur_ecg(last_point_before_QRS)-cur_ecg(first_point_after_QRS);
	amps(i)=range(cur_ecg(last_point_before_QRS:first_point_after_QRS));
	widths(i)=(first_point_after_QRS-last_point_before_QRS)/fs;
	
	% find irregularites
	if length(cur_ecg)>160
		ecg4irreg=cur_ecg(20:end-20);
	else
		ecg4irreg=cur_ecg;
	end
	if length(ecg4irreg)>20
		if mean(abs(diff(ecg4irreg(1:10))))<0.01
			start_amp=mean(ecg4irreg(1:10));
		elseif mean(abs(diff(cur_ecg(max(1,last_point_before_QRS-5):...
				min(length(cur_ecg),last_point_before_QRS+5)))))<0.01
			start_amp=cur_ecg(last_point_before_QRS);
		else
			irregularities(i)=NaN;
		end
		if mean(abs(diff(ecg4irreg(end-9:end))))<0.01
			end_amp=mean(ecg4irreg(end-9:end));
		elseif mean(abs(diff(cur_ecg(max(1,first_point_after_QRS-5):...
				min(length(cur_ecg),first_point_after_QRS+5)))))<0.01
			end_amp=cur_ecg(first_point_after_QRS);
		else
			irregularities(i)=NaN;
		end
	else
		irregularities(i)=NaN;
	end
	if isfinite(irregularities(i))
		if start_amp~=end_amp
			baseline=(start_amp:(end_amp-start_amp)/(length(ecg4irreg)-1):end_amp)';
			n=min(length(ecg4irreg),length(baseline));
			ecg4irreg=ecg4irreg(1:n)-baseline(1:n);
		end
		th1=min(-0.3,0.5*min(ecg4irreg));
		[peaksMax, indsMax]=findpeaks(ecg4irreg); %,'MinPeakHeight',0.0001);
		th2=max(0.3,0.5*max(ecg4irreg));
		[peaksMin, indsMin]=findpeaks(-ecg4irreg); %,'MinPeakHeight',0.001);
		if ~isempty(find(-peaksMin>th2)) || ~isempty(find(peaksMax<th1))
			peak_amps=ecg4irreg([indsMin(-peaksMin>th2);indsMax(peaksMax<th1)]);
			irregularities(i)=0.5;
			if ~isempty(find(abs(peak_amps-cur_ecg(first_point_after_QRS))>0.3 & ...
					abs(peak_amps-cur_ecg(last_point_before_QRS))>0.3 ))
				irregularities(i)=1;
			end
		end

% 		if irregularities(i)>0
% 			fh=figure; 
% 			plot(cur_ecg); 
% 			line([first_point_after_QRS,last_point_before_QRS],cur_ecg([first_point_after_QRS,last_point_before_QRS]),'LineStyle','none','Marker','*');
% 			line(20+1:20+length(ecg4irreg),ecg4irreg);
% 			line(20+indsMax(peaksMax<th1),peaksMax(peaksMax<th1),'LineStyle','none','Marker','*','Color','r');
% 			line(20+indsMin(-peaksMin>th2),-peaksMin(-peaksMin>th2),'LineStyle','none','Marker','*','Color','r');
% 			keyboard;
% 			delete(fh);
% 		end
	end
end