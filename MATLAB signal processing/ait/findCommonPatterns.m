function res=findCommonPatterns(seq)
seq=seq(:);
seq=seq(isfinite(seq));
if isempty(seq)
	res.nConstant_rel=NaN;
	res.nCrossZero_rel=NaN;
	res.nExtrema_rel=NaN;
	res.ratioInDeCreases=NaN;
	res.medianMaxDist=NaN;
	res.iqrMaxDist=NaN;
	res.min=NaN;
	res.max=NaN;
	res.mean=NaN;
	res.std=NaN;
	res.median=NaN;
	res.iqr=NaN;
	res.gini=NaN;
else
	res.nConstant_rel=length(find(diff(seq)==0))/length(seq);
	res.nCrossZero_rel=length(find(diff(sign(seq))~=0))/length(seq);
	minima=find(diff(sign(diff(seq)))>0);
	maxima=find(diff(sign(diff(seq)))<0);
	extrema=sort([minima;maxima]);
	res.nExtrema_rel=length(extrema)/length(seq);
	res.ratioInDeCreases=length(find(diff(seq)>0))/length(find(diff(seq)<0));
	if length(maxima)>1
		res.medianMaxDist=median(diff(maxima));
		res.iqrMaxDist=iqr(diff(maxima));
	else
		res.medianMaxDist=NaN;
		res.iqrMaxDist=NaN;
	end
	res.min=min(seq);
	res.max=max(seq);
	res.mean=mean(seq);
	res.std=std(seq);
	res.median=median(seq);
	res.iqr=iqr(seq);
	res.gini=ginicoeff(seq);
end
% % % fh=figure;
% % % plot(seq);
% % % res
% % % keyboard;
% % % delete(fh);