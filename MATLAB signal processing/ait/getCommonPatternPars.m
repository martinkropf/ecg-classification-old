function res=getCommonPatternPars(dataPerBeat)

for parts={'amp','width','BCI'}
	part=parts{1};
	eval([part,'_res=findCommonPatterns(dataPerBeat.',part,');']);
	eval(['allFieldnames=fieldnames(',part,'_res);']);
	for i=1:length(allFieldnames)
		cur_fieldname=allFieldnames{i};
		eval(['res.',part,'_',cur_fieldname,'=',part,'_res.',cur_fieldname,';']);
	end
end