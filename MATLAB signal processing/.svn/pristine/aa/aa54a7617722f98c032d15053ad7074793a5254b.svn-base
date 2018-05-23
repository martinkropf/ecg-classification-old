function feature_selection()
    ITERATIONS=3;
    result=struct;
    treeTemplate = templateTree(...
    'Surrogate',2,...					'off' (default) | 'on' | 'all' | positive integer value
    'MaxNumSplits',10000,...				default: n-1
    'NumVariablesToSample',30,...		'all' | a number (default: sqrt(nFeatures))
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
    

    load('st0000001.mat');
    load('ait_result_dataset.V38.mat');
    
    res_dataset(:,st0000001) = [];
    res_dataset.Properties.VarNames(:)
    sprintf('Features: %d',size(res_dataset,2));
    [tab,F1_score_full_model]=train_model(treeTemplate,100,get_pars(300),0,0,3,res_dataset);
    disp(size(res_dataset));
    for idx=1:size(res_dataset,2)
        disp(['Testing feature ',int2str(idx),'/',int2str(size(res_dataset,2))]);
        backup=res_dataset(:,idx);
        res_dataset(:,idx) = [];

        [tab,F1_score]=train_model(treeTemplate,100,get_pars(300),0,0,5,res_dataset);
        if round(F1_score,3)<round(F1_score_full_model,3)
            disp(['Score less than with full featureset. Keep important variable',res_dataset.Properties.VarNames(idx)]);
            res_dataset=[res_dataset backup];
        else
            disp(['Score equal or greater than with full featureset. Remove useless variable',res_dataset.Properties.VarNames(idx)]);
        end
    end
    save('newds.mat','res_dataset','-mat');
    result.timestamp= datestr(datetime('now'),'mm.dd.yyyy HH:MM:SS')
    result.results=results;
    result.mean=mean(results);
    result.iterations=length(n_trees);

    filename= [getLocalProperties(),filesep,'results',filesep,'result_',datestr(datetime('now'),'mmddyyyy_HHMMSS'),'.mat']
    save(filename,'result','-mat')
    disp(['Final result ',num2str(mean(results))]);
    dlmwrite('eval_results.csv',results,'-append')

end
