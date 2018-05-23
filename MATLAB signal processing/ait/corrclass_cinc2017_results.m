function [classes,beatTemplates_new,cc_res]=corrclass_cinc2017_results(QRS,classes,beatTemplates)
% destilled from corrclass_cinc2017 - i.e. the part which calculates the results
cc_res.ratioSCsUniqueBeforeCorrection=length(unique(classes))/length(classes);

%% GSc 2017-06-11 get rid of any unstable sequences longer than 5 events
N_DIFFERENT_FOR_NOISE=3;
PERC_IRREGULAR_MIN_FOR_NOISE=2/3*100;
PERC_UNIQUE_CLASSES_MIN_FOR_NOISE=0.75;

n_different_in_a_row_min=[2:10];
classes_blank=classes;
CT=tabulate(classes);
[CT,order] = sortrows(CT,2);
CT=CT(fliplr(order),:);

if 0 % simplification
    s_95=diff(classes)~=0;
    s_is_mainClass=classes==CT(1,1);
    s_95(s_is_mainClass(2:end))=0; % dont count transitions to 1 (mainclass)
    %    different_in_a_row_95_cumsum=cumsum(s_95).*s_95;
else
    s_95=[true diff(classes)~=0];
end
I_end = find(diff(s_95)==-1)+1;
I_start = find(diff(s_95)==1)+1;
if s_95(1)
    I_start = [1 I_start]; % prepend 1 to start indices, assuming that the start of the first unstable sequence was lost
end
if s_95(end) == 1
    I_end = [I_end numel(s_95)]; % append length of s to end indices, assuming that the end of the last unstable sequence was lost
end
if all(s_95) % each class is different - -does lead to empty I_start and I_end
    I_start = 1;
    I_end = numel(s_95);
    %    classes_blank=nan(size(classes)); % make sure, all elements are set to nan
end

different_in_a_row_95 = I_end - I_start;
if ~isempty(different_in_a_row_95)
    %         for i=1:numel(different_in_a_row_95)
    %             cur_seq=classes(I_start(i):I_end(i));
    %             different_in_a_row_95_unique(1,i) =numel(unique(cur_seq));
    %             different_in_a_row_95_unique_wo_1(1,i) = numel(unique(cur_seq))-sum(cur_seq~=1);
    %             different_in_a_row_95_1_to_unique(1,i) = sum(cur_seq==1)/numel(unique(cur_seq));
    %         end
    %         different_in_a_row_95_unique_rel = different_in_a_row_95_unique./different_in_a_row_95;
    %        II=find(different_in_a_row_95>3 & different_in_a_row_95_unique_rel>0.75 & different_in_a_row_95_unique_wo_1>0 & different_in_a_row_95_1_to_unique<1); % more than 75% of events in sequence need to be uniqe
    II=find(different_in_a_row_95>=N_DIFFERENT_FOR_NOISE); % simple but robust criterion
else
    II=[];
end

% blank out noise sequences
rrs=diff(QRS);
median_rr=median(rrs);
for i=1:numel(II)
    cl2blank_inds=I_start(II(i)):I_end(II(i));
    doBlanking_1=0;
    doBlanking_2=0;
    if length(find(abs(rrs(cl2blank_inds(cl2blank_inds<=length(rrs)))-median_rr)>20))/length(cl2blank_inds)*100 > PERC_IRREGULAR_MIN_FOR_NOISE
        % > 50 % der Beats in der Sequenz haben RR-Int != RR-Median
        doBlanking_1=1;
    end
    % GSc 2017-07-02 - check, whether there are at least 50% unique classes
    % in this row - would not be the case, e.g. when it is an alternating
    % sequnce like 1 2 1 2 1 2
    if length(unique(classes(cl2blank_inds)))/length(cl2blank_inds) > PERC_UNIQUE_CLASSES_MIN_FOR_NOISE
        doBlanking_2=1;
    end
    
    if doBlanking_1 & doBlanking_2
        classes_blank(cl2blank_inds)=nan;
    end
    % 	if ~isempty(cl2blank_inds)
    % 		fh=figure('Position',[10,100,1900,900]);
    % 		if doBlanking
    % 			plot(seq,'Color','k');
    % 		else
    % 			plot(seq,'Color','b');
    % 		end
    % 		line(QRS, seq(QRS), 'LineStyle','none','Marker','*','Color','r');
    % 		line(QRS(cl2blank_inds), seq(QRS(cl2blank_inds)), 'LineStyle','none','Marker','*','Color','g');
    % 		text(QRS, seq(QRS), int2str(classes'));
    % 		keyboard;
    % 		delete(fh);
    % 	end
end
if ~all(s_95) % set main class elements back to 1, except in an all different sequence (would lead to single 1s at the beginning or at the end
    classes_blank(classes==CT(1,1))=CT(1,1); % really still needed?
end

classes=classes_blank;
cc_res.n_NaN_rel=sum(isnan(classes))/numel(classes);
cc_res.n_NaN_seq=numel(II);
if ~isempty(different_in_a_row_95)
    cc_res.n_different_in_a_row_95_MAX=max(different_in_a_row_95); % maximum number of different classes in a row
    cc_res.n_different_in_a_row_95_MAX_rel=max(different_in_a_row_95)/numel(classes); % maximum number of different classes in a row relative
else
    cc_res.n_different_in_a_row_95_MAX=0;
    cc_res.n_different_in_a_row_95_MAX_rel=0;
end

cc_res.perc_sc1=length(find(classes>1))/length(classes)*100;
cc_res.perc_sc1_notNaN=length(find(classes(~isnan(classes))>1))/length(classes(~isnan(classes)))*100;

% further NaN parameters
classesWithoutNaNs=classes;
classesWithoutNaNs(isnan(classesWithoutNaNs))=-1; % replace NaNs by -1 to prepare for tabulatioln
CT_nonan=tabulate(classesWithoutNaNs);
[CT_nonan,order] = sortrows(CT_nonan,2);
CT_nonan=CT_nonan(fliplr(order),:);

n_NaN_rank=find(CT_nonan(:,1)==-1);
if ~isempty(n_NaN_rank)
    cc_res.n_NaN_rank=n_NaN_rank;
    cc_res.n_NaN_rel_2_mc=CT_nonan(n_NaN_rank,2)/max(CT_nonan(CT_nonan(:,1)~=-1,2));
    if isempty(cc_res.n_NaN_rel_2_mc)
        cc_res.n_NaN_rel_2_mc=nan;
    end 
else
    cc_res.n_NaN_rank=nan;
    cc_res.n_NaN_rel_2_mc=0;
end
cc_res.perc_sc1_notNaN=100;
cc_res.perc_sc1_notNaN=100;
 

[classes,beatTemplates_new]=sortClasses(classes,beatTemplates); % sort classes according to their frequency of occurence


