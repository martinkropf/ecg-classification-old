function isSpike = detectSpikes(classes,QRS,pars,eventTab)
% DETECTSPIKES - detect events which are most likely spikes
% eventTab .. Table of events
%   adds a new column to eventTab names isSpike with a probability

isSpike=zeros(size(classes)); % default - zero probability
I_spikes=[];
CT=tabulate(classes);
if ~isempty(CT)
    majorClasses=CT(CT(:,2)>2,1);
    majorClasses=CT(1,1);
    classes_prelim=classes;
    classes_prelim(ismember(classes_prelim,majorClasses))=1;
    bci_prelim=diff(QRS)/pars.fs;
    ddclasses=diff(diff(classes_prelim)); % those with different (higher) class in between subclasses of lower class (i.e. more frequent)
    switch pars.detectSpikesMethod
        case 0 % nothing to do
            I_spikes = [];
        case {1,3,4}
            bci_rel=circshift(bci_prelim,-1)./bci_prelim;
            bci_rel(end)=nan;
            bci_cumsum=cumsum(bci_prelim); % GSc 2017-06-24 to avoid interpretation of Nan class beats
            I_spikes1=find(ddclasses<=-2); % those with different (higher) class in between subclasses of lower class (i.e. more frequent)
            I_isSymmetric = classes_prelim(I_spikes1) == classes_prelim(I_spikes1+2); % same SC before and afterwards
            I_spikes1=I_spikes1(I_isSymmetric);
            I_spikes1=I_spikes1(find(I_spikes1>1));
            if ~isempty(I_spikes1)
                I_spikes2=bci_rel(I_spikes1-1) < 0.8 & bci_cumsum(I_spikes1+1) - bci_cumsum(I_spikes1-1) < 1.2*bci_prelim(I_spikes1-1);
                I_spikes=I_spikes1(I_spikes2)+1;
            else
                I_spikes=[];
            end
            if pars.detectSpikesMethod ==3 % GSc 2017-08-15 - spikes are those which classes occur just once - not sure this is a good idea!
                spikeClasses=classes(I_spikes+1);
                spikeClassTab = tabulate(spikeClasses);
                if ~isempty(spikeClassTab)
                    I_spikes(spikeClassTab(spikeClasses,2)>1)=[]; % delete those which occure more than once
                end
            end
        case 5 % GSc 2017-08-19 - Hypothesis: spikes are those where the immediate neighborhood is an excess event?
            ddclasses=diff(diff(classes)); % those with different (higher) class in between subclasses of lower class (i.e. more frequent)
            I_spikes1=find(ddclasses<=-2); % those with different (higher) class in between subclasses of lower class (i.e. more frequent)
            I_isSymmetric = classes_prelim(I_spikes1) == classes_prelim(I_spikes1+2); % same SC before and afterwards
            I_spikes1=I_spikes1(I_isSymmetric);
            I_spikes1=I_spikes1(find(I_spikes1>1));
            for i=1:numel(I_spikes1)
                if sum(eventTab.isExcess(max(1,I_spikes1(i)-1):min(I_spikes1(i)+1,size(eventTab,1))))>0 % at least one event isExcess within range
                    I_spikes(end+1)=I_spikes1(i)+1;
                end
            end
        case 2
            bci_spike=[nan;bci_prelim];
            I_class=find(ddclasses<=-2)+2; % those with different (higher) class in between subclasses of lower class (i.e. more frequent)
            bci_harmMean = 2*bci_spike(1:end-1).*bci_spike(2:end)./(bci_spike(1:end-1) + bci_spike(2:end));
            I_bci=find(bci_harmMean<=0.5);
            I_spikes=I_class(ismember(I_class,I_bci));
        otherwise
            warning('detectEvents: unknown method "%i" - ignored!',pars.detectEventMethod);
    end
    isSpike(I_spikes)=1;
end

