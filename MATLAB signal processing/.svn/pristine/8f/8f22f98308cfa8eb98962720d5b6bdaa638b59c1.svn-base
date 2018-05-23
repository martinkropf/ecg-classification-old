function [corrCoeffs,rms_avbeat,rms_zero]=beatParameters(ecg,QRS,classes,corrWindow,rp,isInverted,avbeats)

if isInverted
	ecg=-ecg;
end
result=[];
right_inds=find(classes==1);
beatInd=find(avbeats.SC==1);
corrCoeffs=ones(size(classes))*NaN;
rms_avbeat=ones(size(classes))*NaN;
rms_zero=ones(size(classes))*NaN;
if ~isfield(avbeats,'seq') || isempty(avbeats.seq{beatInd})
	return
end
corrWindow(1)=max(corrWindow(1),avbeats.window{beatInd}(1));
corrWindow(2)=min(corrWindow(2),avbeats.window{beatInd}(2));
for i=1:length(right_inds)             % Schleife ueber alle Events
	cur_ind=right_inds(i);
	FP=QRS(cur_ind);
	% Beginn des aktuellen Beats bestimmen
	from_wanted=(FP+corrWindow(1));
	if cur_ind>1
		from=max([QRS(cur_ind-1)+rp,0,from_wanted]);
	else
		from=max(1,from_wanted);
	end
	% Ende des aktuellen Beats bestimmen
	to_wanted=FP+corrWindow(end);
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
		from_av=corrWindow(1)-avbeats.window{beatInd}(1)+1;
		from_loaded=1;
		if from_diff>0                              % Es wurden auch Samples vor dem gewuenschten Pkt from geladen -> wieder wegschneiden
			from_loaded=from_diff+1;
		elseif from_diff<0                          % nicht alle gewuenschten Samples konnten geladen werden (wahrscheinlich Sig-Anfang)
			from_av=-from_diff+1;                   % -> nur im tatsaechlich geladenen Bereich mitteln (Problem: immer am Anfang -> wird mit 0 aufgefuellt -> falsch
		end
		to_av=from_av+av_length-1;
		to_loaded=from_loaded+av_length-1;
		
		cur_avbeat=avbeats.seq{beatInd}(from_av:to_av);
		cur_avbeat=cur_avbeat-mean(cur_avbeat);
		this_beat=this_beat(1:to_loaded);
		this_beat=this_beat-mean(this_beat);
		corrCoeff=corrcoef(this_beat,cur_avbeat);
		if length(corrCoeff)>1
			corrCoeffs(cur_ind)=corrCoeff(2,1);
		else
			corrCoeffs(cur_ind)=0;
		end
		rms_avbeat(cur_ind)=sqrt(mean((this_beat-cur_avbeat).^2));
		rms_zero(cur_ind)=sqrt(mean((this_beat).^2));
		
% 		fh=figure; 
% 		subplot(2,1,1);
% 		plot(ecg);
% 		hold on
% 		plot([from:from+length(this_beat)-1],this_beat);
% 		subplot(2,1,2);
% 		plot(this_beat);
% 		hold on
% 		plot(cur_avbeat);
% 		text(0,0,num2str(corrCoeffs));
% 		keyboard;
% 		delete(fh);
	end
end % for i=1:length(right_inds)
