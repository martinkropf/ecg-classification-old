function [QRSrefined,numberOfBeatsWithProblems]=refineQRS(seq,QRS,classes,templates,fs,scw)
% - for similar QRS complexes: use either S or R as fiducial point
% - remove classes that are rather rare and might be noise
numberOfBeatsWithProblems=0;
QRSrefined=QRS;
classes_unique=unique(classes);
classes_unique=classes_unique(classes_unique>0);
SorR=zeros(length(classes_unique),1);
template_length=size(templates.morph,1);
if 0
    figure
    plot(templates.morph);
    legend(strcat('class#: ',int2str(templates.sclass'),', #: ',int2str(templates.count')));
end
for i=1:length(classes_unique)
    morph_curClass=templates.morph(:,i);
    FP=round(-scw(1)*fs)+1;
    if morph_curClass(FP)>mean(morph_curClass([FP-2,FP-1,FP+1,FP+2]))
        SorR(i)='R';
        templates2check=find(SorR(1:i-1)=='S');
        [~,alternative_FP]=min(morph_curClass);
    else
        SorR(i)='S';
        templates2check=find(SorR(1:i-1)=='R');
        [~,alternative_FP]=max(morph_curClass);
    end
    %	if ~isempty(templates2check) && alternative_FP>5 && alternative_FP<2*FP-5
    if ~isempty(templates2check) && alternative_FP>1 && alternative_FP<2*FP-1 % GSc 2017-06-24 - otherwise larger distances between R and S prevent unition
        % only check if alternative_FP is not at the very border
        FP_diff=FP-alternative_FP;
        if FP_diff>0
            cur_from=1;
            others_from=FP_diff+1;
            cur_to=template_length-FP_diff;
            others_to=template_length;
        else
            cur_from=-FP_diff+1;
            others_from=1;
            cur_to=template_length;
            others_to=template_length+FP_diff;
        end
        cc=corr(morph_curClass(cur_from:cur_to),templates.morph(others_from:others_to,templates2check));
        [cc_max,I_cc_max]=max(cc);
        if cc_max>0.95
%         if ~isempty(cc>0.95)
%         if sum(cc>0.95)
            iQRS_orig=find(classes==classes_unique(i));
            for j=1:numel(iQRS_orig)
                testrange=(-3:3); % should finally be tied to fs
                %                    testindex = QRS(iQRS_orig(j))+FP_diff+1+[-5:5];
                testindex = QRS(iQRS_orig(j))-FP_diff+1+testrange;
                testseq=abs(seq(testindex));
                [~,dQRS]=max(testseq);
                if dQRS==1 || dQRS==length(testseq) % sits at the border - most likely not a real extremum
                    % warning(' QRS refinement problem - skipping beat!');
                    numberOfBeatsWithProblems=numberOfBeatsWithProblems+1;
                else
                    QRSrefined(iQRS_orig(j))=testindex(dQRS);
                end
                if 0 % this is to check whether refine QRS worked properly
                    figure;
                    plot(testseq);
                    hold on
                    plot(dQRS,testseq(dQRS),'or');
                    hold off
                end
            end
        end
    end
end