function eval_model()
    ITERATIONS=3;
    result=struct;
    treeTemplate = templateTree(...
    'Surrogate',2,...					'off' (default) | 'on' | 'all' | positive integer value
    'MaxNumSplits',10000,...				default: n-1
    'NumVariablesToSample',10,...		'all' | a number (default: sqrt(nFeatures))
    'MergeLeaves','off',...				'on' | 'off'
    'MinLeaf',1,...
    'Prune','on',...					'on' | 'off'
    'PruneCriterion','impurity',...		'error' | 'impurity'
    'SplitCriterion','deviance',...		'gdi' | 'twoing' | 'deviance' 
    'PredictorSelection','allsplits',...'allsplits' | 'curvature' | 'interaction-curvature'
    'AlgorithmForCategorical','Exact',... 'Exact' | 'PullLeft' | 'PCA' | 'OVAbyClass'
    'MaxNumCategories',30, ...			default: 10
    'QuadraticErrorTolerance',10^-4 ...	default: 10^-4
    );
    

    n_trees=100:100:1000;

    for idx=1:length(n_trees)
        disp(['Iteration ',int2str(idx),'/',int2str(length(n_trees))]);
        [tab,F1_scores]=train_model(treeTemplate,n_trees(idx));
        results(idx)=F1_scores;        
    end
    result.n_trees=n_trees;
    result.timestamp= datestr(datetime('now'),'mm.dd.yyyy HH:MM:SS')
    result.results=results;
    result.mean=mean(results);
    result.iterations=length(n_trees);

    filename= [getLocalProperties(),filesep,'results',filesep,'result_',datestr(datetime('now'),'mmddyyyy_HHMMSS'),'.mat']
    save(filename,'result','-mat')
    disp(['Final result ',num2str(mean(results))]);
    dlmwrite('eval_results.csv',results,'-append')

end
