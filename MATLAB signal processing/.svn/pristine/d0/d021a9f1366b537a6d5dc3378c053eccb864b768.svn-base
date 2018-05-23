function [isInverted, doInversion, res]=checkForLeadInversion(seq,QRS,fs,signQRSdetCinc,pars)
res=struct;
isInverted=0;
doInversion=0;
ratioNMin=0;
ratioAmpsMin=0;
if pars.checkForLeadInversion.method==1
	% Lead Inversion based on S or R from Cinc QRS Detector
	if signQRSdetCinc<=0
		doInversion=1;
		isInverted=1;
	end
elseif pars.checkForLeadInversion.method>=2
	QRS=QRS(QRS<length(seq)+1);
	nRbeats=length(find(seq(QRS)>seq(QRS+1)));
	nSbeats=length(find(seq(QRS)<seq(QRS+1)));
	isS=0;
	if nRbeats<nSbeats 
		isS=1;
		[min_peaks,min_locations]=findpeaks(-seq,...
			'MinPeakHeight',pars.checkForLeadInversion.minPeakHeight,...
			'MinPeakWidth',pars.checkForLeadInversion.minPeakWidth*fs,...
			'MaxPeakWidth',pars.checkForLeadInversion.maxPeakWidth*fs);
		[max_peaks,max_locations]=findpeaks(seq,...
			'MinPeakHeight',pars.checkForLeadInversion.minPeakHeight,...
			'MinPeakWidth',pars.checkForLeadInversion.minPeakWidth*fs,...
			'MaxPeakWidth',pars.checkForLeadInversion.maxPeakWidth*fs);

		% zu knapp beieinander liegende Peaks loeschen
		ddseq=diff(diff(seq));
		right_min=find(min_locations<length(seq)-2 & min_locations>2);
		right_min=right_min(abs(ddseq(min_locations(right_min)-1))<pars.checkForLeadInversion.peakDistMin);
		min_locations=min_locations(right_min);
		right_max=find(max_locations<length(seq)-2 & max_locations>2);
		right_max=right_max(abs(ddseq(max_locations(right_max)-1))<pars.checkForLeadInversion.peakDistMin);
		max_locations=max_locations(right_max);
		min_peaks=min_peaks(right_min);
		max_peaks=max_peaks(right_max);

		% Peaks gleich neben QRS loeschen - koennte noch beschleunigt werden
		QRS_blank_samp=round(pars.checkForLeadInversion.QRSblankInterval*fs);
		QRS_ignore_inds=zeros(length(QRS),QRS_blank_samp*2+1);
		cnt=1;
		for i=-QRS_blank_samp:QRS_blank_samp
			QRS_ignore_inds(1:length(QRS),cnt)=QRS+i;
			cnt=cnt+1;
		end
		QRS_ignore_inds=QRS_ignore_inds(:);
		[min_locations,min_inds]=setdiff(min_locations,QRS_ignore_inds);
		[max_locations,max_inds]=setdiff(max_locations,QRS_ignore_inds);
		min_peaks=min_peaks(min_inds);
		max_peaks=max_peaks(max_inds);
		ratioNMin=length(min_locations)/(length(max_locations)+length(min_locations));
		ratioAmpsMin=sum(min_peaks)/(sum(min_peaks)+sum(max_peaks));
		if ratioNMin>0.5 ||...	% mehr neg. als pos. P und T-Wellen
				ratioAmpsMin>pars.checkForLeadInversion.amplitudeFactor	% viel ausgepraegtere neg. Wellen
			isInverted=1;
		end
	% % % 	fh=figure('Position',[10,500,2000,500]);
	% % % 	if isInverted
	% % % 		col='r';
	% % % 	else
	% % % 		col='b';
	% % % 	end
	% % % 	plot(seq,'color',col);
	% % % 	set(gca,'XLim',[5,30]*fs);
	% % % 	line(QRS,seq(QRS),'LineStyle','none','marker','*');
	% % % 	line(min_locations,seq(min_locations),'Color','m','linestyle','none','marker','*');
	% % % 	line(max_locations,seq(max_locations),'Color','k','linestyle','none','marker','*');
	% % % 	keyboard;
	% % % 	delete(fh);
	end
	if isInverted || (isS && pars.checkForLeadInversion.method==2)
		doInversion=1;
	end
end
if pars.checkForLeadInversion.addFeatures
	res.isInverted=isInverted;
	res.isS=isS;
	res.ratioNMin=ratioNMin;
	res.ratioAmpsMin=ratioAmpsMin;
end