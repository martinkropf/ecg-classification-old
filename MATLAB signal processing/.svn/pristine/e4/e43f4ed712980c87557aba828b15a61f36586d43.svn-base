function [result,avbeat]=avbeat_cinc2017(ecg,QRS,classes,fs,pars,isInverted)

avbeat=[];
result=[];
avwindow=pars.avbeat.avwindow;
rp=pars.avbeat.rp;
npointsmin=pars.avbeat.npointsmin;

%% AV-Beats berechnen
classes_unique=unique(classes(~isnan(classes)));
nbeats=0;
avwindow=round(avwindow*fs);
nsamps=max(avwindow)-min(avwindow);
rp=round(rp*fs);
for j=1:length(classes_unique)
	SC=classes_unique(j);
	nbeats=nbeats+1;
	right_inds=find(classes==SC);
	
	average=zeros(nsamps,1);
	beats_per_point=zeros(nsamps,1);
	for i=1:length(right_inds)             % Schleife ueber alle Events
		cur_ind=right_inds(i);
		FP=QRS(cur_ind);
		% Beginn des aktuellen Beats bestimmen
		from_wanted=(FP+avwindow(1));
		if cur_ind>1
			from=max([QRS(cur_ind-1)+rp,0,from_wanted]);
		else
			from=max(1,from_wanted);
		end
		% Ende des aktuellen Beats bestimmen
		to_wanted=FP+avwindow(end);
		if cur_ind<length(QRS)
			to=min([QRS(cur_ind+1)-rp,length(ecg),to_wanted]);
		else
			to=min(to_wanted,length(ecg));
		end
		% aktuellen Beat laden und gemittelten Beat aktualisieren
		if to>from
			this_beat=ecg(from:to);
			this_beat=this_beat-mean(this_beat);
			
			to=from+length(this_beat);
			from_diff=from_wanted-from;
			av_length=min([to_wanted,to])-max([from_wanted,from]);
			from_av=1;
			from_loaded=1;
			if from_diff>0                              % Es wurden auch Samples vor dem gewuenschten Pkt from geladen -> wieder wegschneiden
				from_loaded=from_diff+1;
			elseif from_diff<0                          % nicht alle gewuenschten Samples konnten geladen werden (wahrscheinlich Sig-Anfang)
				from_av=-from_diff+1;                   % -> nur im tatsaechlich geladenen Bereich mitteln (Problem: immer am Anfang -> wird mit 0 aufgefuellt -> falsch
			end
			to_av=from_av+av_length-1;
			to_loaded=from_loaded+av_length-1;
			weights=beats_per_point(from_av:to_av);
			average(from_av:to_av)=(average(from_av:to_av).*weights+this_beat(from_loaded:to_loaded))./(weights+1);
			beats_per_point(from_av:to_av)=beats_per_point(from_av:to_av)+1;
		end
	end % for i=1:length(right_inds)
	nmin=max(beats_per_point)*npointsmin;
	first_found=find(beats_per_point>nmin,1,'first');							% ab diesem Zt-Punkt vor dem FP wurden genug beats dieser klasse gefunden
	last_found=find(beats_per_point>nmin,1,'last');								% bis zu ------- II ---------
	average=average(first_found:last_found);
	found_window=avwindow(1)+[first_found,last_found];
	if ~isempty(found_window) && found_window(2)<=0
		found_window=[];
		average=[];
	end
	
	% 	if length(average) > 2*nsamp_optionalWindow && ...
	% 			mean(abs(diff(average(1:nsamp_optionalWindow)))) > mean(abs(diff(average(nsamp_optionalWindow:2*nsamp_optionalWindow))))
	% 		average=average(nsamp_optionalWindow:end);
	% 		found_window(1)=found_window(1)+nsamp_optionalWindow-1;
	% 	end
	
	avbeat.seq{nbeats}	=average;
	avbeat.window{nbeats}=found_window;
	avbeat.SC(nbeats)	=SC;
	avbeat.isEctopicClass(nbeats)=0;
	
	%% ---------------- Erkennen vn Ectopic beats --------------------------
	% mit den hier gefundenen Grenzen von QRS die QRS amp und QRS width
	% berechnen
	SUBCLASSES_ONLY=1;
	if pars.avbeat.checkEctopic && (~SUBCLASSES_ONLY || SC>1) && ...
			~isempty(found_window) && found_window(2)>0 && found_window(1)<0 && found_window(1)<-1
		samp_FP=-found_window(1);
		samp_right_end=min(length(average),samp_FP+0.3*fs);
		first_point_after_QRS=getQRSendPoint(average(samp_right_end:-1:samp_FP),0.03*fs,-0.005,1/20);
		first_point_after_QRS=samp_right_end-first_point_after_QRS;
		last_point_before_QRS=getQRSendPoint(average(1:samp_FP),0.03*fs,-0.005,1/20);
		width=(first_point_after_QRS-last_point_before_QRS)/fs;
		
		% Pruefen, ob nach R eine deutliche S-Zacke kommt. Falls ja, fuer
		% Ectopic-Beat-Erkennung diese verwenden
		for inv=0:1
			if inv
				av2use=-average;
				first_point_after_QRS=getQRSendPoint(av2use(samp_right_end:-1:samp_FP),0.03*fs,-0.005,1/20);
				first_point_after_QRS=samp_right_end-first_point_after_QRS;
				last_point_before_QRS=getQRSendPoint(av2use(1:samp_FP),0.03*fs,-0.005,1/20);
			else
				av2use=average;
			end
			[S_amp,possible_S]=min(av2use(last_point_before_QRS:first_point_after_QRS));
			possible_S=last_point_before_QRS-1+possible_S;
			if possible_S>samp_FP && possible_S<first_point_after_QRS
				if S_amp<-0.02
					samp_FP=possible_S;
				end
			end
			
			if av2use(samp_FP)<av2use(1)	% Es muss eine S-Zacke dominieren
				if width>0.1				% QRS muss breiter als 100 ms sein
					% es muss T direkt an QRS folgen
					first_descending_after_peak=samp_FP+find(diff(av2use(samp_FP:end))<0,1,'First');
					if first_descending_after_peak > samp_FP+0.15*fs
						first_ascending_after_decending=first_descending_after_peak+find(diff(av2use(first_descending_after_peak:end))>0,1,'First');
						if first_ascending_after_decending > first_descending_after_peak + 0.05*fs
							avbeat.isEctopicClass(nbeats)=1;
							break;
						end
					end
				end
			end
		end
	end
	
	% % %     	% avbeat plotten
	% % %     	fh=figure;
	% % %     	plot(average);
	% % %     	line([last_point_before_QRS,first_point_after_QRS],average([last_point_before_QRS,first_point_after_QRS]),'Linestyle','none','marker','*');
	% % %     	line([samp_FP],average([samp_FP]),'Linestyle','none','marker','*');
	% % %     	x_min=min(average);
	% % %     	text(20,x_min+0.1,['width=',num2str(width)]);
	% % %     	text(20,x_min+0.2,['amp=',num2str(amp)]);
	% % %     	text(20,x_min+0.3,['t to T=',num2str((first_descending_after_peak-samp_FP)/fs)]);
	% % %     	if avbeat.isEctopicClass(nbeats)==1
	% % %     		text(20,x_min+0.5,'ECTOPIC BEAT','Color','r','FontSize',20);
	% % %     	end
	% % %     	line([first_descending_after_peak],average([first_descending_after_peak]),'Linestyle','none','marker','*','Color','r');
	% % %     	line([first_ascending_after_decending],average([first_ascending_after_decending]),'Linestyle','none','marker','*','Color','r');
	% % %     	keyboard;
	% % %     	delete(fh);
end % for j=1:length(classes_unique)

%% get characteristic points and amplitude / interval paramaters for max. the first 2 classes
for j=1:max(2,length(classes_unique))
	if isempty(avbeat) || ~isfield(avbeat,'SC') || length(avbeat.SC)<j
		avbeat.SC(j)=0;
	end
	avbeat=getCharacteristicPoints(avbeat,j,fs,classes,pars,QRS,isInverted);
	av_fieldnames=fieldnames(avbeat);
	start_field_ind=find(strcmp(av_fieldnames,'QRS_on'));
	if j<=2
		for k=start_field_ind:length(av_fieldnames)
			eval(['result.',av_fieldnames{k},'_',int2str(j),'=avbeat.',av_fieldnames{k},'(',int2str(j),');']);
		end
	end
end
SCs=avbeat.SC>0;
for k=1:length(av_fieldnames)
	avbeat.(av_fieldnames{k})=avbeat.(av_fieldnames{k})(SCs>0);
end

if isempty(avbeat.SC)
	result.nOtherRhythmBeats=0;
else
	[avbeat,result]=detectOtherRhythmBeats(avbeat,result,pars);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function getCharacteristicPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function all_avbeats=getCharacteristicPoints(all_avbeats,av_index,fs,classes,pars,QRS,isInverted)
QRS_width=NaN;
QRS_amp=NaN;
QRS_off=NaN;
QRS_on=NaN;
ST_elevation=NaN;
T_amp=NaN;
P_amplitude2=nan;
P_amplitude2rel=nan;
P_onset=nan;
P_offset=nan;
P_duration=nan;
PQ_int=nan;
P_amplitude4=nan;
P_area=NaN;
ST_gradient=nan;
isWPW=NaN;
isWPW_rising=NaN;
R_up_gradient_change=nan;
R_up_gradient=nan;
R_down_gradient_change=nan;
R_down_gradient=nan;
FP_amp=nan;
nbeats=nan;
Q_FP_time=nan;
QT_duration=nan;
T_off=NaN;
PoffQRSon_int=NaN;
P_angle = nan;
P_area = nan;
P_skewness = nan;
P_isinverse_1 = nan;
P_isinverse_2 = nan;
QRS_t_on2off=nan;
QRS_a_on2off=nan;
QRS_A_on2off=nan;
P_angle=NaN;
P_area = NaN;
P_skewness = NaN;

classes_unique=unique(classes(~isnan(classes)));

n_beats_min=4;
if length(classes_unique)>=av_index
	nbeats=length(find(classes==classes_unique(av_index)));
else
	nbeats=0;
end
if av_index<=2 && length(classes_unique)>=av_index && ...	% Subklasse 1 oder 2
		nbeats>=n_beats_min && ...
		~isempty(all_avbeats.window{av_index}) && all_avbeats.window{av_index}(1)<0				% mind n_beats_min events fuer diesen AV-Beat
	% nur, wenn der avbeat aus mind. n_beats_min Beats gebaut wurde
	av_seq=all_avbeats.seq{av_index};
	if isInverted
		av_seq=-av_seq;
		disp('inverted');
	end
	av_window=all_avbeats.window{av_index};
	samp_FP=-av_window(1);
	
	%% Optimalen Beginn des AV-Beats bestimmen
	best_start=1;
	if  ~isempty(av_seq) && samp_FP>0.15*fs && length(av_seq)>samp_FP
		start_av=av_seq(1:samp_FP);
		shift_max=5;
		seq_shift_block=start_av;
		for shift=1:shift_max
			seq_shift_block(1:end-shift,shift+1)=start_av(shift+1:end);
		end
		start_av_filt=mean(seq_shift_block(1:end-shift_max,:),2);
		pars.avbeat.preferredStartWindow(1)=max(pars.avbeat.preferredStartWindow(1),pars.avbeat.avwindow(1));
		nTotal=round(-pars.avbeat.avwindow(1)*fs);
		endFront=nTotal-round(-pars.avbeat.preferredStartWindow(1)*fs);
		startRear=nTotal-round(-pars.avbeat.preferredStartWindow(2)*fs);
		delay_penalty=[(2*(endFront:-1:1)-1), zeros(1,startRear-endFront-1), (startRear:nTotal)-startRear]'/1000;
		delay_penalty=delay_penalty(nTotal-samp_FP+1:end-shift_max);
		%
		% 		n_with_delay_penalty_rear=min(length(start_av_filt),round(0.2*fs));
		% 		n_without_delay_penalty=max(0,length(start_av_filt)-n_with_delay_penalty_rear);
		%
		%
		% 		delay_penalty=[zeros(1,n_without_delay_penalty),((1:n_with_delay_penalty_rear)-1)/1000]';
		diff_penalty=abs(diff(start_av_filt)-median(diff(start_av_filt)))*10;
		amp_penalty=abs(start_av_filt-median(start_av_filt(abs(diff(start_av_filt))<0.002)))/5;
		penalty_sum=delay_penalty(1:end-1)+diff_penalty+amp_penalty(1:end-1);
		[~,best_start]=min(penalty_sum);
		while best_start>1 && (...
				penalty_sum(best_start-1)<penalty_sum(best_start)*1.1 || ...
				penalty_sum(best_start-1)<0.01)
			best_start=best_start-1;
		end
		
		
		% % % 		fh=figure;
		% % % 		plot(start_av);
		% % % 		line(1:length(start_av_filt),start_av_filt,'Color','r');
		% % % 		line(1:length(diff_penalty),diff_penalty,'Color','g');
		% % % 		line(1:length(amp_penalty),amp_penalty,'Color','m');
		% % % 		line(1:length(delay_penalty),delay_penalty,'Color','k');
		% % % 		line(1:length(penalty_sum),penalty_sum,'Color','c','LineWidth',2);
		% % % 		line(best_start,start_av(best_start),'Color','r','Marker','*');
		% % % 		keyboard;
		% % % 		delete(fh);
		
	end %  ~isempty(av_seq) && samp_FP>0.15*fs && length(av_seq)>samp_FP
	
	
	
	%% QRS onset
	QRS_on=getQRSendPoint(av_seq(best_start:samp_FP),0.03*fs,-0.005,1/20);
	QRS_on=QRS_on+best_start-1;
	% Geraden durch sample 1 und QRSon
	if av_seq(best_start)~=av_seq(QRS_on)
		ref_line2=(av_seq(best_start):(av_seq(QRS_on)-av_seq(best_start))/...
			(QRS_on-best_start):av_seq(QRS_on))';
	else
		ref_line2=av_seq(best_start)*ones((QRS_on-best_start+1),1);
	end
	% Pruefen, ob die Gerade am Anfang des avbeat und direkt vor QRS_on mehr
	% oder weniger dem Signal entspricht.
	to_ref=min(length(ref_line2),QRS_on-best_start+1);
	from_ref=max(2,to_ref-5);
	to_av=to_ref+best_start-1;
	from_av=from_ref+best_start-1;
	if mean(abs(av_seq(from_av:to_av)-ref_line2(from_ref:to_ref))) > 0.005
		% Falls nicht: QRS_on verschieben versuchen
		[~,ind]=min(abs(diff(av_seq(from_av-1:to_av-1))));
		delta=5-ind;
		QRS_on_test=max(1,QRS_on-delta);
		ref_line_test=(av_seq(best_start):(av_seq(QRS_on_test)-av_seq(best_start))/...
			(QRS_on_test-best_start):av_seq(QRS_on_test))';
		to_test_ref=min(length(ref_line_test),QRS_on_test-best_start+1);
		from_test_ref=max(1,to_test_ref-5);
		to_test_av=to_test_ref+best_start-1;
		from_test_av=from_test_ref+best_start-1;
		if mean(abs(av_seq(from_test_av:to_test_av)-ref_line_test(from_test_ref:to_test_ref))) < ...
				mean(abs(av_seq(from_av:to_av)-ref_line2(from_ref:to_ref)))
			QRS_on=QRS_on_test;
			to_ref=to_test_ref;
			to_av=to_test_av;
			ref_line2=ref_line_test;
		end
	end

	%% P wave
	% GSc 2017-08-06 - alterantive p wave analysis & Parameter, die auf dem Dreieck P_on, P_peak, P_off
	% basieren
	if pars.avbeat.partOfBCIbeforQRS2look4Pwave
		if QRS_on>0.02*fs
			qrs=nan(size(QRS));
			qrs(classes==av_index)=QRS(classes == av_index);
			bci_est=mean(diff(qrs),'omitnan');
			%             if isfield(pars,'BCI_est') % shift start of p-wave search with bci estimation
			%                 from = max(ceil(QRS_on - pars.BCI_est*pars.partOfBCIbeforQRS2look4Pwave),1);
			%             else
			%                 from = 1;
			%             end
			from = max(ceil(QRS_on - bci_est*pars.partOfBCIbeforQRS2look4Pwave),1);
			to = to-fs*0.01; % stay away from QRS_on a bit
			p_seq=detrend(av_seq(from:to),'linear');
			P_isinverse_1 = mean(diff(p_seq).*[1:length(p_seq)-1]');
			[~,xdmax]=max(diff(p_seq));
			[~,xdmin]=min(diff(p_seq));
			P_isinverse_2 = xdmax - xdmin;
			if P_isinverse_1 > 0 %  negative p Wave? invert
				p_seq = - p_seq;
			end
			% Geraden durch sample 1 und sample end
			ref_line3=(p_seq(1):(p_seq(end)-p_seq(1))/(numel(p_seq)-1):p_seq(end))';

			if 0 % simple version
				[P_amp,P_peak]=max(p_seq);
				P_onset=max(find(abs(p_seq(1:P_peak))<0.01 | ...
					abs(p_seq(1:P_peak))<P_amp/3));
				P_offset=P_peak-1+min(find(abs(p_seq(P_peak:end))<0.01 | ...
					abs(p_seq(P_peak:end))<P_amp/3));
			else % same as previously
				[P_amp,P_peak]=max(p_seq-ref_line3);
				P_onset=max(find(abs(p_seq(1:P_peak)-ref_line3(1:P_peak))<0.01 | ...
					abs(p_seq(1:P_peak)-ref_line3(1:P_peak))<P_amp/3));
				P_offset=P_peak-1+min(find(abs(p_seq(P_peak:end)-ref_line3(P_peak:end))<0.01 | ...
					abs(p_seq(P_peak:end)-ref_line3(P_peak:end))<P_amp/3));

			end
			P_On = [P_onset/fs; p_seq(P_onset)];
			P_Off = [P_offset/fs; p_seq(P_offset)];
			P_Ext = [P_peak/fs; p_seq(P_peak)];
			P_peak=P_peak+from-1;
			P_onset=P_onset+from-1;
			P_offset=P_offset+from-1;
			P_duration=(P_offset-P_onset)/fs;
			PQ_int=(QRS_on-P_onset)/fs;
			if P_duration<0.03 || P_duration>0.15
				P_amplitude4=0;
				PQ_int=NaN;
			else
				P_amplitude4=P_amp;
			end
			if P_amplitude4<0.03
				PQ_int=NaN;
			end
		end
		if ~isnan(P_onset) & ~isnan(P_offset) & ~isnan(P_peak) & P_duration
			P_On = [P_onset/fs; p_seq(P_onset)];
			P_Off = [P_offset/fs; p_seq(P_offset)];
			P_Ext = [P_peak/fs; p_seq(P_peak)];
			L1 = P_Ext - P_On;
			L2 = P_Off - P_Ext;
			P_d1 = P_Ext(1) - P_On(1);
			P_d2 = P_Off(1) - P_Ext(1);
			P_angle = acos( dot(L1,L2) / (norm(L1) * norm(L2)) ); % Winkel zwischen den beiden Linien in rad
			P_area = L1'*L2;
			P_skewness = 2*(P_d1 - P_d2)/(P_d1 + P_d2); % a measure of p Wave asymmetry
		end
		if 0 % comprehensive visualisation
			fh=findobj('Tag','average');
			if ishandle(fh)
				figure(fh)
			else
				figure('Tag','average');
			end
			plot(av_seq);
			text(from,av_seq(from),'|');
			text(to,av_seq(to),'|');
			p_seq_x=(0:length(p_seq)-1)+from;
			line(p_seq_x,p_seq,'Color','k');
			lh1=line([P_onset P_peak],av_seq([P_onset P_peak]),'Color','g');
			lh2=line([P_peak P_offset],av_seq([P_peak P_offset]),'Color','r');
		end

	else % pars.avbeat.partOfBCIbeforQRS2look4Pwave: "old" version
		if QRS_on>0.05*fs + best_start
			QRS_amp_coarse=av_seq(max(best_start,samp_FP))-av_seq(to_av); % nur eine grobe Schaetzung
			if mean(abs(av_seq(best_start:best_start+9)-ref_line2(1:10))) < pars.avbeat.P_dist_ref_max &&...
					mean(abs(av_seq(to_av-5:to_av)-ref_line2(to_ref-5:to_ref))) < pars.avbeat.P_dist_ref_max
				% nur wenn die ref-line am Anfang und Ende gut mit dem Sig
				% uebereinstimmt...

				% P2: Mittlerer Abstand des anfaenglichen Signals von der Ref-Line
				P_amplitude2=abs(mean(av_seq(best_start:to_av)-ref_line2(1:to_ref)));
				if P_amplitude2>range(av_seq)*0.3
					P_amplitude2=0;
				end
				P_amplitude2rel=P_amplitude2/QRS_amp_coarse;

				% P4: Maximaler Abstand des anfaenglichen Signals von der Ref-Linie
				% allerdings diesmal nur, wenn auch P-Duration Sinn macht
				if pars.avbeat.searchNegativePwaves
					[P_amp,P_peak_ref]=max(abs(av_seq(best_start:to_av)-ref_line2(1:to_ref)));
				else
					[P_amp,P_peak_ref]=max(av_seq(best_start:to_av)-ref_line2(1:to_ref));
				end
				P_peak=P_peak_ref+best_start-1;
				P_onset=best_start-1+max(find(abs(av_seq(best_start:P_peak)-ref_line2(1:P_peak_ref))<0.01 | ...
					abs(av_seq(best_start:P_peak)-ref_line2(1:P_peak_ref))<P_amp/3));
				P_offset=P_peak-1+min(find(abs(av_seq(P_peak:to_av)-ref_line2(P_peak_ref:to_ref))<0.01 | ...
					abs(av_seq(P_peak:to_av)-ref_line2(P_peak_ref:to_ref))<P_amp/3));
				P_duration=(P_offset-P_onset)/fs;
				PQ_int=(QRS_on-P_onset)/fs;
				PoffQRSon_int=(QRS_on-P_offset)/fs;
				if P_duration<pars.avbeat.P_duration_min || P_duration>pars.avbeat.P_duration_max
					P_amplitude4=0;
					PQ_int=NaN;
					PoffQRSon_int=NaN;
					P_onset=NaN;
					P_offset=NaN;
					P_area=NaN;
				else
					P_amplitude4=P_amp;
					if av_seq(P_onset)~=av_seq(P_offset)
						P_zeroline=av_seq(P_onset):(av_seq(P_offset)-av_seq(P_onset))/(P_offset-P_onset):av_seq(P_offset);
					else
						P_zeroline=ones(1,P_offset-P_onset+1)*av_seq(P_onset);
					end
					P_area=sum(av_seq(P_onset:P_offset)-P_zeroline');
					if ~isnan(P_onset) && ~isnan(P_offset) && ~isnan(P_peak) && P_duration>0
						P_On = [P_onset/fs; av_seq(P_onset)];
						P_Off = [P_offset/fs; av_seq(P_offset)];
						P_Ext = [P_peak/fs; av_seq(P_peak)];
						L1 = P_Ext - P_On;
						L2 = P_Off - P_Ext;
						P_d1 = P_Ext(1) - P_On(1);
						P_d2 = P_Off(1) - P_Ext(1);
						P_angle = acos( dot(L1,L2) / (norm(L1) * norm(L2)) ); % Winkel zwischen den beiden Linien in rad
						P_skewness = 2*(P_d1 - P_d2)/(P_d1 + P_d2); % a measure of p Wave asymmetry
					end

				end
				if P_amplitude4<pars.avbeat.P_amp_min % 0.03
					PQ_int=NaN;
					PoffQRSon_int=NaN;
					P_onset=NaN;
					P_offset=NaN;
				end
			end
		end

		% % % 	fh=figure;
		% % % 	plot(av_seq);
		% % % 	line(best_start,av_seq(best_start),'Color','r','LineStyle','none','marker','*');
		% % % 	if isfinite(P_onset), line(P_onset,av_seq(P_onset),'Color','g','LineStyle','none','marker','*'); end
		% % % 	if isfinite(P_offset), line(P_offset,av_seq(P_offset),'Color','g','LineStyle','none','marker','*');end
		% % % 	line(QRS_on,av_seq(QRS_on),'Color','r','LineStyle','none','marker','*');
		% % % 	keyboard;
		% % % 	delete(fh);

		%% P und T Welle mit CinC-Algorithmus zur Punkt-Bestimmung finden
		% Funktioniert eigentlich nicht => vorerst ausgeremt (muesste in avbeat
		% erst sauber integriert werden)
		%
		% P wave
		% % % 	%% Methode 3
		% % % 	af_res.P_amplitude3=0;
		% % % 	af_res.n_peaks_p=0;
		% % % 	if length(pseq_avbeat)>=30
		% % % 		P=findpeaksx(1:length(pseq_avbeat),pseq_avbeat,0.0001,0.01,0,2,3);
		% % % 		af_res.n_peaks_p=size(P,1);
		% % % 		af_res.P_amplitude3=P(:,3)+abs(mean(pseq_avbeat([1:10])));
		% % % 		if size(P,1)>1
		% % % 			af_res.P_amplitude3=0;
		% % % 		end
		% % % 	end
		% % %
		% T wave
		% % % T_window=av_twave_window;
		% % % right_av_ind=avbeats.SC==1;
		% % % av_window=avbeats.window{right_av_ind};
		% % % av_seq_T=avbeats.seq{right_av_ind};
		% % % tseq_avbeat=av_seq_T(max(1,-av_window(1)+round(T_window(1)*fs)):end);
		% % % if length(tseq_avbeat)>0
		% % % 	T=findpeaksx(1:length(tseq_avbeat),tseq_avbeat,0.0001,0.01,2,2,3);
		% % % 	af_res.n_peaks_t=size(T,1);
		% % % 	af_res.T_amplitude=0;
		% % % 	if length(tseq_avbeat)>=30
		% % % 		af_res.T_amplitude=T(:,3)+abs(mean(tseq_avbeat([1:10])));
		% % % 		if size(T,1)>1
		% % % 			af_res.T_amplitude=mean(T(:,3))+abs(mean(tseq_avbeat([1:10])));
		% % % 		end
		% % % 	end
		% % % 	af_res.P_T_ratio=af_res.P_amplitude4/af_res.T_amplitude;
		% % % else
		% % % 	af_res.T_amplitude=-1;
		% % % 	af_res.n_peaks_t=-1;
		% % % 	af_res.P_T_ratio=-1;
		% % % end

		%% Find the most probable ST segment
		ST_candidate_window=samp_FP+pars.avbeat.ST_candidate_window(1)*fs:...
			min(samp_FP+pars.avbeat.ST_candidate_window(2)*fs,length(av_seq));
		ST_candidate_seq=av_seq(ST_candidate_window);
		shift_max=5;
		seq_shift_block=ST_candidate_seq;
		for shift=1:shift_max
			seq_shift_block(1:end-shift,shift+1)=ST_candidate_seq(shift+1:end);
		end
		block_instability=range(diff(seq_shift_block),2);
		block_gradient=mean(diff(seq_shift_block),2);
		ST_decision_function=pars.avbeat.instab_factor*block_instability+...	ST sollte moeglichst eine gerade sein
			pars.avbeat.gradient_factor*abs(block_gradient)+...					ST sollte moeglichst horizontal verlaufen
			pars.avbeat.late_factor*(1:length(block_gradient))';			% ST sollte moeglichst nahe an QRS sein
		ST_decision_function=ST_decision_function(1:end-shift);
		[~,best_st]=min(ST_decision_function);
		if ~isempty(best_st) && (best_st==1 || best_st==length(ST_decision_function))
			best_st=[];
		else
			ST_gradient=block_gradient(best_st);
			% 	ST_gradient=mean(block_gradient(max(1,best_st-2):min(length(block_gradient),best_st+2)));
			best_st=ST_candidate_window(best_st)+round(shift_max/2);
		end

		%% Find QRS offset
		if ~isempty(best_st)
			QRSoff_candidate_window=samp_FP:best_st;
			QRSoff_candidate_seq=av_seq(QRSoff_candidate_window);
			shift_max=5;
			seq_shift_block=QRSoff_candidate_seq;
			for shift=1:shift_max
				seq_shift_block(1:end-shift,shift+1)=QRSoff_candidate_seq(shift+1:end);
			end
			block_instability=range(diff(seq_shift_block),2);
			block_gradient=mean(diff(seq_shift_block),2);
			QRSoff_decision_function=pars.avbeat.instab_factor*block_instability+...	ST sollte moeglichst eine gerade sein
				pars.avbeat.gradient_factor*abs(block_gradient)+...					ST sollte moeglichst horizontal verlaufen
				pars.avbeat.late_factor*(1:length(block_gradient))';			% ST sollte moeglichst nahe an QRS sein
			QRSoff_decision_function=QRSoff_decision_function(1:end-shift);
			QRS_off=find(QRSoff_decision_function>pars.avbeat.QRS_off_th,1,'Last');
			QRS_off=QRSoff_candidate_window(QRS_off); %-round(shift_max/2);

			if mean(abs(av_seq(max(best_start,to_av-5):to_av)-ref_line2(max(1,to_ref-5):to_ref))) < 0.02
				% 			mean(abs(av_seq(best_start:best_start+9)-ref_line2(1:10))) < pars.avbeat.P_dist_ref_max &&...

				QRS_width=(QRS_off-QRS_on)/fs;
				QRS_amp=range(av_seq(QRS_on:QRS_off));
				T_amp=range(av_seq(QRS_off:end));
				if isfinite(P_offset)
					ST_elevation=mean(av_seq(QRS_off:best_st))-mean(av_seq(P_offset:QRS_on));
				else
					ST_elevation=mean(av_seq(QRS_off:best_st))-...
						mean(av_seq(max(1,QRS_on-round(0.05*fs)):QRS_on));
				end
			end
		end
		if ~isempty(QRS_on) && ~isempty(QRS_off) && ~isnan(QRS_on) && ~isnan(QRS_off)
			QRS_t_on2off=av_seq(QRS_off)-av_seq(QRS_on);
			QRS_a_on2off=av_seq(QRS_on)-av_seq(QRS_off);
			QRS_A_on2off=QRS_t_on2off*QRS_a_on2off;
		end
		%% Find T offset
		if length(av_seq)>samp_FP+0.5*fs
			T_seq=av_seq(best_st:end);
			if ~isempty(QRS_off) && isfinite(QRS_off) && QRS_off<length(av_seq)-0.25*fs
				start1=QRS_off;
			else
				start1=QRS_on+round(0.02*fs)-1+min(find(diff(sign(...
					av_seq(QRS_on+round(0.02*fs):end)-av_seq(QRS_on)))~=0)); % wird dann doppelt gerechnet...
			end
			x1=start1:length(av_seq);
			x2=1:length(av_seq);
			x3=QRS_on:length(av_seq);
			y1=av_seq(start1):(av_seq(end)-av_seq(start1))/(length(x1)-1):av_seq(end);
			y2=av_seq(1):(av_seq(end)-av_seq(1))/(length(x2)-1):av_seq(end);
			y3=av_seq(QRS_on):(av_seq(end)-av_seq(QRS_on))/(length(x3)-1):av_seq(end);
			T_seq=zeros(length(av_seq),3);
			n=min(length(x1),length(y1)); T_seq(x1(1:n),1)=av_seq(x1(1:n))-y1(1:n)';
			n=min(length(x2),length(y2)); T_seq(x2(1:n),2)=av_seq(x2(1:n))-y2(1:n)';
			n=min(length(x3),length(y3)); T_seq(x3(1:n),3)=av_seq(x3(1:n))-y3(1:n)';
			minToAnyRefLine=min(abs(T_seq),[],2);
			[T_amp,T]=max(minToAnyRefLine(start1:end));
			T=start1-1+T;
			if T<length(minToAnyRefLine)-5
				T_off1=T-1+find(minToAnyRefLine(T:end-5)<T_amp/10 & ...
					minToAnyRefLine(T+1:end-4)<T_amp/15 & ...
					minToAnyRefLine(T+2:end-3)<T_amp/15 & ...
					minToAnyRefLine(T+3:end-2)<T_amp/15 & ...
					minToAnyRefLine(T+4:end-1)<T_amp/15 & ...
					minToAnyRefLine(T+5:end)<T_amp/15 ...
					,1,'First');
				T1_first_crossing=T-1+find(diff(sign(T_seq(T:end,1))),1,'First');
				T2_first_crossing=T-1+find(diff(sign(T_seq(T:end,2))),1,'First');
				T3_first_crossing=T-1+find(diff(sign(T_seq(T:end,3))),1,'First');
				T_off2=median([T2_first_crossing,T2_first_crossing,T3_first_crossing]);

				x4=[];
				if		(isempty(T1_first_crossing) || T1_first_crossing>length(av_seq)-10) && ...
						(isempty(T2_first_crossing) || T2_first_crossing>length(av_seq)-10) && ...
						(isempty(T3_first_crossing) || T3_first_crossing>length(av_seq)-10) && ...
						(isempty(T_off1) || T_off1 > length(av_seq)-0.08*fs)
					% Die 3 Ref-Linien passen alle nicht - eine weitere
					% Ref-Linie vom 0.2*T zum Ende verwenden
					x4=T:length(av_seq);
					y4=av_seq(T)/5:(av_seq(end)-av_seq(T)/5)/(length(x4)-1):av_seq(end);
					n=min(length(x4),length(y4));T_seq4=av_seq(x4(1:n))-y4(1:n)';
					T_off1=T+find(T_seq4<T_amp/10,1,'first');
				end

				if ~isempty(T_off1)
					T_off=min(T_off1,T_off2);
				else
					T_off=T_off2;
				end

				if T_off>length(av_seq)-20
					T_off=[];
				else
					T_amp = av_seq(T)-(av_seq(start1)+av_seq(T_off))/2;
					QT_duration=T_off-QRS_on;
				end

				% 			fh=figure; plot(av_seq);
				% 			line(x1,y1); line(x2,y2); line(x3,y3);
				% 			if ~isempty(x4)
				% 				line(x4,y4);
				% 				line(x4,T_seq4,'Color','r');
				% 			end
				% 			line(start1,av_seq(start1),'marker','*','Color','g');
				% 			line(T,av_seq(T),'marker','*');
				% 			line(T_off1,av_seq(T_off1),'marker','*','Color','m');
				% 			line(T_off,av_seq(T_off),'marker','*','Color','r');
				% 			line(T1_first_crossing,0,'Marker','v','Color','g');
				% 			line(T2_first_crossing,0,'Marker','v','Color','k');
				% 			line(T3_first_crossing,0,'Marker','v','Color','b');
				% 			hold on;
				% 			plot(T_seq,'LineStyle',':');
				% 			keyboard;
				% 			delete(fh);
			end
		end


		%% Steigung etc. in der ansteigenden R-Zacke
		if QRS_on>0.05*fs && ~isempty(QRS_off) && isfinite(QRS_off)
			if av_seq(QRS_on) > av_seq(samp_FP)
				% S => invertieren
				QRS_seq=-av_seq(QRS_on:QRS_off);
				inverted=1;
			else
				QRS_seq=av_seq(QRS_on:QRS_off);
				inverted=0;
			end
			FP=samp_FP-QRS_on+1;

			[Qamp,Q]=min(QRS_seq(1:FP));
			R_rise_inds=Q:FP;
			if length(R_rise_inds)>4
				R_up_gradient=mean(diff(QRS_seq(R_rise_inds)));
			end
			if length(R_rise_inds)>8
				mid=round(length(R_rise_inds)/2);
				% 			R_up_gradient_change=mean(diff(av_seq(R_rise_inds(1:mid))))/...
				%				mean(diff(av_seq(R_rise_inds(mid:end))));
				R_up_gradient_change=median(diff(QRS_seq(R_rise_inds(1:mid))))/...
					median(diff(QRS_seq(R_rise_inds(mid:end))));
			end

			[Samp,S]=min(QRS_seq(FP:end));
			R_fall_inds=FP:length(QRS_seq);
			if length(R_fall_inds)>4
				R_down_gradient=mean(diff(QRS_seq(R_fall_inds)));
			end
			if length(R_fall_inds)>8
				mid=round(length(R_fall_inds)/2);
				% 			R_up_gradient_change=mean(diff(av_seq(R_rise_inds(1:mid))))/...
				%				mean(diff(av_seq(R_rise_inds(mid:end))));
				R_down_gradient_change=median(diff(QRS_seq(R_fall_inds(1:mid))))/...
					median(diff(QRS_seq(R_fall_inds(mid:end))));
			end
			if inverted
				R_up_gradient=-R_up_gradient;
				R_up_gradient_change=-R_up_gradient_change;
				R_down_gradient=-R_down_gradient;
				R_down_gradient_change=-R_down_gradient_change;
			end
		end
		% % % 	fh = figure;
		% % % 	plot(av_seq);
		% % % 	line(ST_candidate_window,av_seq(ST_candidate_window),'color','r')
		% % % 	line(ST_candidate_window(1:length(block_gradient)),block_gradient);
		% % % 	line(ST_candidate_window(1)+(1:length(ST_decision_function)),ST_decision_function,'Color','k');
		% % % 	line(best_st,av_seq(best_st),'Marker','*');
		% % % 	line(QRSoff_candidate_window(1)+(1:length(QRSoff_decision_function)),QRSoff_decision_function,'Color','g');
		% % % 	line(QRS_off,av_seq(QRS_off),'Marker','*','Color','k');
		% % % 	keyboard
		% % % 	delete(fh);

		%% Detect WPW
		isWPW=0;
		isWPW_rising=0;
		if pars.avbeat.checkWPW
			% Erkennen on WPW-Syndrom - Verbreiterung im abfallenden Ast von R
			WPW_window_falling=max(1,samp_FP-1):min(samp_FP+round(0.1*fs),length(av_seq));
			if length(WPW_window_falling)>5
				isWPW=detectWPW(av_seq,WPW_window_falling,fs,samp_FP,QRS_on);
			end
			if pars.avbeat.checkWPW==2
				% steigender Ast von R
				av_seq_for_rising=fliplr(av_seq')';
				WPW_window_rising=1+length(av_seq)-samp_FP:1+length(av_seq)-max(1,samp_FP-round(0.1*fs));
				if length(WPW_window_rising)>5
					isWPW_rising=detectWPW(av_seq_for_rising,WPW_window_rising,fs,length(av_seq)-samp_FP-1,1+length(av_seq)-QRS_off);
				end
				% 	if isWPW_rising>0
				% 		fh=figure; plot(av_seq);
				% 		keyboard;
				% 		delete(fh);
				% 	end
			end
		end
		if ~isempty(QRS_on), Q_FP_time=samp_FP-QRS_on; end
	end % else pars.
end  % if av_index<=2 

%% Write result to all_avbeats
if isempty(QRS_off), QRS_off=nan; end
if isempty(QRS_width), QRS_width=nan; end
if isempty(QRS_amp), QRS_amp=nan; end
if isempty(T_amp), T_amp=nan; end
if isempty(T_off), T_off=nan; end
if isempty(QT_duration), QT_duration=nan; end
if isempty(ST_gradient), ST_gradient=nan; end

all_avbeats.QRS_on(av_index)=QRS_on;
all_avbeats.nbeats(av_index)=nbeats;
all_avbeats.FP_amp(av_index)=FP_amp;
all_avbeats.QRS_off(av_index)=QRS_off;
all_avbeats.P_on(av_index)=P_onset;
all_avbeats.P_off(av_index)=P_offset;
all_avbeats.QRS_width(av_index)=QRS_width;
all_avbeats.QRS_amp(av_index)=QRS_amp;
all_avbeats.ST_elevation(av_index)=ST_elevation;
all_avbeats.isWPW(av_index)=isWPW;
all_avbeats.isWPW_rising(av_index)=isWPW_rising;
all_avbeats.P_amplitude2(av_index)=P_amplitude2;
all_avbeats.P_amplitude2rel(av_index)=P_amplitude2rel;
all_avbeats.P_amplitude4(av_index)=P_amplitude4;
all_avbeats.P_area(av_index)=P_area;
all_avbeats.P_duration(av_index)=P_duration;
all_avbeats.PQ_int(av_index)=PQ_int;
all_avbeats.PoffQRSon_int(av_index)=PoffQRSon_int;
all_avbeats.ST_gradient(av_index)=ST_gradient;
all_avbeats.R_up_gradient(av_index)=R_up_gradient;
all_avbeats.R_up_gradient_change(av_index)=R_up_gradient_change;
all_avbeats.R_down_gradient(av_index)=R_down_gradient;
all_avbeats.R_down_gradient_change(av_index)=R_down_gradient_change;
all_avbeats.Q_FP_time(av_index)=Q_FP_time;
all_avbeats.QT_duration(av_index)=QT_duration;
all_avbeats.T_amp(av_index)=T_amp;
all_avbeats.T_off(av_index)=T_off;
all_avbeats.P_angle(av_index)=P_angle;
all_avbeats.P_area(av_index)=P_area;
all_avbeats.P_skewness(av_index)=P_skewness;
all_avbeats.P_isinverse_1(av_index)=P_isinverse_1;
all_avbeats.P_isinverse_2(av_index)=P_isinverse_2;
all_avbeats.P_isinverse_2(av_index)=P_isinverse_2;
all_avbeats.QRS_t_on2off(av_index)=QRS_t_on2off;
all_avbeats.QRS_a_on2off(av_index)=QRS_a_on2off;
all_avbeats.QRS_A_on2off(av_index)=QRS_A_on2off;
all_avbeats.P_angle(av_index)=P_angle;
all_avbeats.P_skewness(av_index)=P_skewness;
end

%% -----------------------------------------------------------------------
function isWPW=detectWPW(av_seq,WPW_window,fs,FP_samp,QRS_on)
[all_maxPeaks,all_maxPeak_inds]=findpeaks(av_seq(WPW_window),'MinPeakDistance',min(floor(length(WPW_window)/4),0.01*fs));
all_maxPeak_inds=WPW_window(1)+all_maxPeak_inds;
[all_minPeaks,all_minPeak_inds]=findpeaks(-av_seq(WPW_window),'MinPeakDistance',min(floor(length(WPW_window)/4),0.01*fs));
all_minPeak_inds=WPW_window(1)+all_minPeak_inds;
all_minPeaks=-all_minPeaks;
[~,all_wendePunktR_inds]=findpeaks(diff(av_seq(WPW_window)),'MinPeakDistance',min(floor(length(WPW_window)/4),0.01*fs));
all_wendePunktR_inds=WPW_window(1)+all_wendePunktR_inds;
all_wendePunktRAmps=av_seq(all_wendePunktR_inds);
[~,all_wendePunktL_inds]=findpeaks(-diff(av_seq(WPW_window)),'MinPeakDistance',min(floor(length(WPW_window)/4),0.01*fs));
all_wendePunktL_inds=WPW_window(1)+all_wendePunktL_inds;
all_wendePunktLAmps=av_seq(all_wendePunktL_inds);
point_amps=[all_maxPeaks;all_minPeaks;all_wendePunktRAmps;all_wendePunktLAmps];
point_inds=[all_maxPeak_inds;all_minPeak_inds;all_wendePunktR_inds;all_wendePunktL_inds];
point_types=[ones(size(all_maxPeak_inds))*'A';...
	ones(size(all_minPeak_inds))*'V';...
	ones(size(all_wendePunktR_inds))*'R';...
	ones(size(all_wendePunktL_inds))*'L']';
[~,order]=sort(point_inds);
postQRS_types=char(point_types(order));
point_amps=point_amps(order);

if isempty(QRS_on) || ~isfinite(QRS_on)
	isWPW=0;
	return
end
FP_amp=av_seq(FP_samp)-av_seq(QRS_on);

if length(point_amps)<10 && length(point_amps)>=5 && ...
		(any(strfind(postQRS_types,'ALRLV')==1) ||...
		any(strfind(postQRS_types,'ALRLRLV')==1))&& ...					Plateau und dann ein Minimum
		point_amps(3)>av_seq(QRS_on)-0.1 && ...			Plateau ist nicht weit unter PQ-Linie
		point_amps(5)>av_seq(QRS_on)-0.2				  % Minimum nach Plateau ist nicht weiter unter PQ-Linie
	isWPW=point_amps(3)-point_amps(5);
	% 		disp(['Plateua - WPW = ',num2str(isWPW),' - QRS_w = ',num2str(QRS_width)]);
elseif length(point_amps)<13 && length(point_amps)>=7 && ... 19.7. 13 statt 10
		(any(strfind(postQRS_types,'ALVRALV')==1) || ...
		any(strfind(postQRS_types,'ALVRALR')==1))&& ...					P-Welle direkt nach R
		point_amps(3)>av_seq(QRS_on)-0.1 && ...			erstes Minimum ist nicht weit unter PQ-Linie
		point_amps(5)<av_seq(QRS_on)+FP_amp*0.5 && ...	Maximum der 2. P-Welle ist nicht allzu hoch
		point_amps(5)>(point_amps(7)+point_amps(3))/2+FP_amp*0.04 && ...	Maximum der 2. P-Welleist nicht allzu niedrig (19.7. 0.01 statt 0.08)
		point_amps(7)<point_amps(3)+0.05							%	zweites Minimum ist nicht viel hoeher als erstes (erstes darf kein S sein)
	isWPW=10*(point_amps(5)-point_amps(7));
	% 		disp(['P-Wave - WPW = ',num2str(isWPW),' - QRS_w = ',num2str(QRS_width)]);
else
	isWPW=0;
end
end

%% Detect beat morphologies that only appear in O-class
function [avbeats,result]=detectOtherRhythmBeats(avbeats,result,pars)
isE=zeros(length(avbeats.nbeats),1);
for j=1:length(avbeats.nbeats)
	nbeats=avbeats.nbeats(j);
	seq=avbeats.seq{j};
	avbeats.isOtherRhythmBeat(j)=0;
	if nbeats>=pars.avbeat.nBeatsOtherRhythmDetectionMin && ...
			~isempty(avbeats.window{j}) && ...
			avbeats.window{j}(1)<0 && (-avbeats.window{j}(1))<length(seq)
		QRS_on=avbeats.QRS_on(j);
		T_amp=avbeats.T_amp(j);
		QRS_width=avbeats.QRS_width(j);
		ST_elevation=avbeats.ST_elevation(j);
		if ~isempty(QRS_on) && isfinite(QRS_on)
			offset=mean(seq(max(1,QRS_on-5):QRS_on));
			seq=seq-offset;
		end
		isS=(seq(-avbeats.window{j}(1))<seq(1));
		if (isS && T_amp<0 && QRS_width>0.1 && abs(seq(1))<=0.02) ||...
				avbeats.isEctopicClass(j) ||...
				(-avbeats.window{j}(1)>15 && seq(-avbeats.window{j}(1)-15)>0.1) || ...
				(~isS && ~isempty(T_amp) && T_amp<0 && T_amp>-0.5 && avbeats.Q_FP_time(j)<50 && ~isempty(ST_elevation) && ST_elevation<-0.2 && QRS_width>0.1) || ... ST-Streckensenkung
				(isS && ~isempty(T_amp) && T_amp>0 && ~isempty(ST_elevation) && ST_elevation > 0.2 ) ||...
				T_amp>1
			isE(j)=isE(j)+nbeats;
			if pars.avbeat.setOtherRhythmBeatsEctopic
				avbeats.isEctopicClass(j)=1;
			end
			avbeats.isOtherRhythmBeat(j)=1;
		end
	end
end
result.nOtherRhythmBeats=sum(isE);
end