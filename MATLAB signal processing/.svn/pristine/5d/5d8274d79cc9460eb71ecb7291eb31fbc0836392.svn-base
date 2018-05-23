function [ classes_new,beatTemplates_new ] = sortClasses( classes,beatTemplates )
%% Sort classification elements according to frequency
% GSc 2017-08-12
CT=tabulate(classes);
if ~isempty(CT) % would be the case, e.g. if all classes are NaN
    CT = sortrows(CT,2);
    CT=CT(end:-1:1,:);
%    cc_res.perc_sc1_notNaN=CT(1,3);
    
    ind=find(CT(:,1)>0 & CT(:,2)>0); % those classes higher than 1 and with at lest 1 element
    %[n,ind]=sort(beats.count,'descend');
    % classes_new=classes;
    classes_new=nan(size(classes));
    for i=1:length(ind)
        classes_new(classes==CT(ind(i),1))=i;
    end
%    classes=classes_new;
    %    inds2keep=ismember(beats.sclass,CT(ind,1));
    [Lia,inds2keep]=ismember(CT(ind,1),beatTemplates.sclass);
    % GSc 2017-06-23 - need to also sort other elements of beats structure
    beatTemplates_new.sclass=1:i;
    beatTemplates_new.count=beatTemplates.count(inds2keep);
    beatTemplates_new.last=beatTemplates.last(inds2keep);
    beatTemplates_new.checked=beatTemplates.checked(inds2keep);
    beatTemplates_new.archive=beatTemplates.archive(inds2keep);
    beatTemplates_new.corr=beatTemplates.corr(:,inds2keep);
    beatTemplates_new.morph=beatTemplates.morph(:,inds2keep);
else
    inds2keep=[];
    i=0;
    classes_new=classes;
    beatTemplates_new=beatTemplates;
%    cc_res.perc_sc1_notNaN=0;
end


end

