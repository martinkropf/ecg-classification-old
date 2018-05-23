function optimizeEnsemble

nTestsPerPar=5;

possibleValues=struct(...
	'Surrogate',[],...
	'MaxNumSplits',[],...
	'NumVariablesToSample',[],...
	'MergeLeaves',[],...
	'MinLeaf',[],...
	'Prune',[],...
	'PruneCriterion',[],...
	'SplitCriterion',[],...
	'PredictorSelection',[],...
	'AlgorithmForCategorical',[],...
	'MaxNumCategories',[],...
	'QuadraticErrorTolerance',[]...
);
resultValues=struct(...
	'Surrogate',[],...
	'MaxNumSplits',[],...
	'NumVariablesToSample',[],...
	'MergeLeaves',[],...
	'MinLeaf',[],...
	'Prune',[],...
	'PruneCriterion',[],...
	'SplitCriterion',[],...
	'PredictorSelection',[],...
	'AlgorithmForCategorical',[],...
	'MaxNumCategories',[],...
	'QuadraticErrorTolerance',[]...
);

possibleValues.Surrogate={2,'off','on','all'};											% 2 best, hardly any effect
possibleValues.MaxNumSplits={10000,[],1000};											% 10000 best
possibleValues.NumVariablesToSample={[],10,'all',8,12,15};								% 10 best
possibleValues.MergeLeaves={'off','on'};												% off best
possibleValues.MinLeaf={1,2,3,4,5};														% 1 best
possibleValues.Prune={'on','off'};														% on best
possibleValues.PruneCriterion={'impurity','error'};										% impurity best
possibleValues.SplitCriterion={'deviance','gdi','twoing'};								% deviance best
possibleValues.PredictorSelection={'allsplits', 'curvature','interaction-curvature'};	% allsplits best
possibleValues.AlgorithmForCategorical={'Exact','PullLeft','PCA','OVAbyclass'};			% best: Exact
possibleValues.MaxNumCategories={30,2,5,8,10,15,20};									% best: 30
possibleValues.QuadraticErrorTolerance={10^-4,1.2*10^-4,0.8*10^-4};						% best: 10^-4 

nTreeValues={1000,100,150,200,300,500,800,2000};									% 1000 is best but slower, 150, 200, 300 and 500 are similar

possibleParameters=fieldnames(possibleValues);
for i=1:length(possibleParameters)+1
	if i>length(possibleParameters)
		vals=nTreeValues;
	else
		vals=possibleValues.(possibleParameters{i});
	end
	F1=zeros(nTestsPerPar*length(vals),1);
	groups=zeros(nTestsPerPar*length(vals),1);
	buildTreeStringBasis='treeTemplate=templateTree(';
	for j=1:length(possibleParameters)
		if i~=j
			vals2=possibleValues.(possibleParameters{j});
			basisVal=vals2{1};
			if isempty(basisVal)
				buildTreeStringBasis=[buildTreeStringBasis,'''',possibleParameters{j},''',[],'];
			elseif isnumeric(basisVal)
				buildTreeStringBasis=[buildTreeStringBasis,'''',possibleParameters{j},''',',num2str(basisVal),','];
			else
				buildTreeStringBasis=[buildTreeStringBasis,'''',possibleParameters{j},''',''',basisVal,''','];
			end
		end
	end
	for j=1:length(vals)
		cur_val=vals{j};
		if i>length(possibleParameters)
			nTrees=cur_val;
			buildTreeString=[buildTreeStringBasis(1:end-1),');'];
			cur_name='nTrees';
		else
			nTrees=nTreeValues{1};
			if isempty(cur_val)
				buildTreeString=[buildTreeStringBasis,'''',possibleParameters{i},''',[],'];
			elseif isnumeric(cur_val)
				buildTreeString=[buildTreeStringBasis,'''',possibleParameters{i},''',',num2str(cur_val),','];
			else
				buildTreeString=[buildTreeStringBasis,'''',possibleParameters{i},''',''',cur_val,''','];
			end
			buildTreeString=[buildTreeString(1:end-1),');'];
			cur_name=possibleParameters{i};
		end
		
		treeTemplate=[]; % just to avoid warining - will be overwritten by eval
		eval(buildTreeString);
		
		for k=1:nTestsPerPar
			disp(['********************************** par ',int2str(i), ' val ',int2str(j),' try ',int2str(k)]);
			[~,F1(nTestsPerPar*(j-1)+k)]=train_model(treeTemplate,nTrees);
			groups(nTestsPerPar*(j-1)+k)=j;
		end
	end
	[p,fh]=statplot(F1,groups,'all');
	set(fh,'Name',cur_name);
	pause(0.001);
	resultValues.(possibleParameters{i})=F1;
end