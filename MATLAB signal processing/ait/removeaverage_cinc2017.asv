function [atrial_seq, atrial_seq2,res]=removeaverage_cinc2017(ecg,QRS,classes,avbeats,fs,pars)

nevs=length(QRS);
dist=round(pars.removeaverage.dist*fs);
b=pars.removeaverage.b;
a=pars.removeaverage.a;
lmovav=pars.removeaverage.lmovav;

nsamp=length(ecg);
atrial_seq=ecg;
atrial_seq2=ecg;
for ev_ind=1:nevs
    FP=QRS(ev_ind);
	
	%% 1) Mittleren Beat abziehen. 
	SC=classes(ev_ind);

	from_seq_wanted=FP+lmovav(1);
	if ev_ind>1
		from_seq=max([1,from_seq_wanted,QRS(ev_ind-1)+dist]);
	else
		from_seq=max([1,from_seq_wanted]);
	end
	from_seq_diff=from_seq-from_seq_wanted;
	
	to_seq_wanted=FP+lmovav(2);
	if ev_ind<nevs
		to_seq=min([nsamp,to_seq_wanted,QRS(ev_ind+1)-dist]);
	else
		to_seq=min([nsamp,to_seq_wanted]);
	end
	to_seq_diff=to_seq_wanted-to_seq;
	
	if ~isempty(avbeats)
		right_av_ind=find(avbeats.SC==SC);
		if ~isempty(right_av_ind)
			av_window=avbeats.window{right_av_ind};
			av_seq=avbeats.seq{right_av_ind};

			if ~isempty(av_window) && ~isempty(av_seq)
				from_av_wanted=-av_window(1)+lmovav(1)+from_seq_diff;
				from_av=max(1,from_av_wanted);
				from_av_diff=from_av-from_av_wanted;
				from_seq=from_seq+from_av_diff;

				to_av_wanted=-av_window(1)+lmovav(2)-to_seq_diff;
				to_av=min(length(av_seq),to_av_wanted);
				to_av_diff=to_av_wanted-to_av;
				to_seq=to_seq-to_av_diff;

				% lineare Korrektur durchfuehren (1. und letzten sample auf 0 setzen)
				av_beat=av_seq(from_av:to_av);
				if ~isempty(av_beat)
					av_beat=av_beat-av_beat(1);
					av_beat=av_beat-((0:length(av_beat)-1)'/length(av_beat))*av_beat(end);

					% gemittelten Beat abziehen
					atrial_seq(from_seq:to_seq)=atrial_seq(from_seq:to_seq)-av_beat;
					atrial_seq2(from_seq:to_seq)=atrial_seq2(from_seq:to_seq)-av_beat;
				end
			end
		end
	else
		atrial_seq(from_seq:to_seq)=0;
		atrial_seq2(from_seq:to_seq)=0;
	end
	
	%% 2) QRS-Komplex trotzdem noch blanken (lineares Interpolieren des Signals innerhalb des Blanking-Windows)			
	window1=max(1,FP-dist  ):min(nsamp,FP+dist  );		% Fenster, in dem geplankt wird
	window2=max(1,FP-dist*3):min(nsamp,FP+dist*3);		% Fenster, anhand dessen interpoliert wird
	window3=max(1,FP-round(dist/2)):min(nsamp,FP+round(dist/2));	% Fenster, in dem linear interpoliert wird
	known_window=sort([setdiff(window2,window1),window3]);			% Bereichinnerhalb von window 2, wo Seq. gleich bleiben soll

	% im Zentralen Bereich des blanking Windows linear interpolieren
	border_amps=atrial_seq(window1([1,end]));				% Ampl direkt vor/nach blanking-window

	if (max(border_amps)-min(border_amps))~=0
		atrial_seq(window1)=border_amps(1)+...
			(1:length(window1))*diff(border_amps)/length(window1);
	else
		atrial_seq(window1)=border_amps(1);
	end
	% im Randbereich spline verwenden
	seq=atrial_seq(known_window);
	seq=filtfilt(b,a,seq);
	seq=spline(known_window,seq,window2);
	atrial_seq(window1)=seq(window1(1)-window2(1)+1:window1(end)-window2(1)+1);
end
res.mean_amp_before_qrsBlank=mean(atrial_seq2);
res.mean_amp_before_qrsBlank_rel=res.mean_amp_before_qrsBlank/mean(ecg);
res.mean_amp_after_qrsBlank=mean(atrial_seq);
res.mean_amp_after_qrsBlank_rel=res.mean_amp_after_qrsBlank/mean(ecg);
res.ampRatio_qrsBlank=res.mean_amp_before_qrsBlank/res.mean_amp_after_qrsBlank;

%% Erg plotten
% fh=figure('Position',[10,200,2000,500]);
% plot(ecg(1000:3000));
% hold on;
% plot(atrial_seq(1000:3000));
% keyboard;
% delete(fh);
