function [classes,beats]=corrclass_cinc2017(seq,QRS,fs,scw,ccmin)
newSC_cnt=0;
maxSC=0;
beats=struct('morph',[],'sclass',[],'last',[],'checked',[],'count',[]);
classes=zeros(size(QRS));
sc_win=round(scw*fs);
%% Schleife ueber alle Events
for i=1:length(QRS)
    FP=QRS(i);
    I_sc=FP+(sc_win(1):sc_win(2));
    nsamp=length(seq);
    if I_sc(1)<1 || I_sc(end)>nsamp												% Bereichsüberschreitung
        SC=0;																	% nicht wegwerfen, nur SC=0 setzen (da sie nicht berechnet werden kann)
    else
        lbeat=length(I_sc);
        [nSamps,nBeats]=size(beats.morph);
        % erstmal hinzufügen
        newSC_cnt=newSC_cnt+1;
        SC=maxSC+1;
        beats.count(nBeats+1)=1;
        beats.last(nBeats+1)=FP;
        beats.archive(nBeats+1)=0;
        beats.sclass(nBeats+1)=0;
        beats.checked(nBeats+1)=0;
        beats.sclass(nBeats+1)=SC;
        
        beats.morph(1:lbeat,nBeats+1)=seq(I_sc)-mean(seq(I_sc));
        beats.corr(nBeats+1)=0;
        cc_vec=arcs_corcoefvec(beats.morph)';
        if isempty(cc_vec)
            % erster beat
            beats.corr(i,nBeats+1)=0;
        else
            beats.corr(i,nBeats+1)=max(cc_vec);
        end
        I_cc=find(cc_vec>ccmin)';
        if ~isempty(I_cc)														% Übereinstimmung mit mindestens einer Klasse
            I_cc=[I_cc, nBeats+1];
            SC=beats.sclass(I_cc(1));
            beats.last(I_cc(1))=max(beats.last(I_cc));
            N=sum(beats.count(I_cc));
            % Arithmetische, gewichtete Mittelwerte
            factors=ones(size(beats.morph(:,I_cc(1))))*beats.count(I_cc);
            beats.morph(:,I_cc(1))=...
                sum(beats.morph(:,I_cc).*factors,2)/N;
            
            % Mittelwerte der einzelnen Beats abziehen
            beats.morph(:,I_cc(1))=...
                beats.morph(:,I_cc(1)) - ...
                ones(nSamps,1)*mean(beats.morph(:,I_cc(1)));
            beats.corr(I_cc(1))=...
                sum(beats.corr(I_cc).*beats.count(I_cc),2)/N;
            beats.count(I_cc(1))=N;
            beats.count(I_cc(2:end))=0;
        end
        classes(ismember(classes,beats.sclass(I_cc)))=SC;
        beats=delete_empty_beats(beats);
    end
    classes(i)=SC;
    maxSC=max(classes);
end

function beats=delete_empty_beats(beats)
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
