function point=getQRSendPoint(seq,window_Q,th_Q_abs,th_Q_rel)
% point=getQRSendPoint(seq)
%
% DHa 2017-05-18
%
% Detect the end of the QRS complex by finding the point with highest
% distance to the line drawn from the R peak to the first sample of the seq
% after norming both X and Y of the seq to 1
% If the mean(diff(x)) right before the point found is smaller than either 
% th_Q_abs or max(seq)*th_Q_rel, it is considered that a Q peak is found 
% and the procedure is repeated with the inverted signal, taking the 
% inverted Q as R

seq=seq(:);
if seq(end)<seq(1)
	seq=seq(1)-seq;
end
seq=seq-seq(1);
y=seq/seq(end);
x=(1:length(seq))'/length(seq);
ref_dists=sqrt((2*(x/2-y/2).^2)');
[~,point]=max(ref_dists);
diff_before_point=mean(diff(seq(max(point-round(window_Q),1):point)));
if isfinite(diff_before_point) && ...
		(diff_before_point<-max(diff(seq))*th_Q_rel || ...
		diff_before_point<th_Q_abs) && point>1
	start=max(1,point-2*(length(seq)-point));

% 	fh=figure; 
% 	plot(seq);
% 	line([start,point],seq([start,point]),'linestyle','none','marker','*');
% 	keyboard;
% 	delete(fh);

	seq=-seq(start:point);
	point=start+getQRSendPoint(seq,window_Q,th_Q_abs,th_Q_rel)-1;
end



