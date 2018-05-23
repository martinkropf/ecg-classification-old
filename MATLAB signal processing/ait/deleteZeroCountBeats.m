function beats=delete_empty_beats(beats)
% delete elements from structure which have zero count
Idle=find(~beats.count);
if ~isempty(Idle)
    beats.morph(:,Idle)=[];
    beats.count(Idle)=[];
    beats.sclass(Idle)=[];
    beats.last(Idle)=[];
    beats.corr(:,Idle)=[];
    beats.archive(Idle)=[];
    beats.checked(:,Idle)=[];
end
