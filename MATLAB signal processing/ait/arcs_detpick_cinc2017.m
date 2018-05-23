function [dlist,dd,qrs_range,n_not_sel,iqr_qrs,res_det]=arcs_detpick(aseqd,...
    blank_func,dmin,nmin,nmax,Tmax,shall_resolve_ds,mustContain,doGini)
% [dlist,dd]=arcs_detpick(aseqd,blank_func,dmin,nmin,nmax,Tmax)
%
% GS 2001-04-05 - ausgelagert in eigene Datei
%
% 1. Punkte mit maximaler Ableitung solange herauspicken, bis
%	 kein überschwelliger Wert mehr vorhanden
% 2. Abschneiden der Serie beim Punkt des größten relativen Abfalls
%	 (deutlichster Sprung), wobei mindestens nmin genommen werden
%
% Uebergabeparameter:
%	dd = Maß für die Deutlichkeit des Abbruchkriteriums
%	aseqd		Absolutwerte der 1.Ablt. d. Signals
%	blank_func  Blanking Function. Immer, wenn ein neuer QRS-Komplex
%				gefunden wurde, wird aseqd im Bereich um diesen Punkt herum
%				mit der blanc_func multipliziert
%	dmin		Schwellwert; Minimale 1.Ablt. fuer Detektion
%	nmin		Minimale Anzahl an Punkten, die herausgepikt werden
%	nmax		max. --II--
%	Tmax		max Abstand zw. 2 gefundenen Beats
%
%
% GS 2001-04-14 - nmax hinzugefügt (optional)
% DH 2003-11-24 statt FP+RP(1) <-> FP+RP(2) wird immer der Bereich FP+/-max(RP)
% ausgeremt (denn auch sonst liegt einer der Evs. im Ref-Bereich des anderen)

if nargin < 3 || isempty(dmin)
    dmin=0;
end
if nargin < 4 || isempty(nmin)
    nmin=0;
end
if nargin < 5 || isempty(nmax)
    nmax=inf;																% entspricht "keine Obergrenze"
end
if nargin < 6 || isempty(Tmax)
    Tmax=inf;
end
if nargin < 7 || isempty(shall_resolve_ds)
    shall_resolve_ds = 0;
end
if nargin < 8 || isempty(mustContain)
    mustContain=[];
end
if nargin < 9 || isempty(doGini)
    doGini = 0;
end

dlist=[];
dd=0;
D=[];
lowest_qrs = 0;
highest_nonqrs = 0;
i=1;
nblank=length(blank_func);
blankdist=floor(nblank/2);
dmax=dmin;
nsamp=length(aseqd);
min_dmax=inf;
qrs_range=inf;
dmax_new = 3; % mV

% 1) Nur in den ueberschwelligen Bereichen suchen -------------------------
%right_inds=find(aseqd>dmin);
right_inds=find(aseqd>dmin & aseqd<dmax_new);
if isempty(right_inds)
    % empty channel
    return;
end

%right_inds=find(aseqd<3);
right_aseqd=[0;aseqd(right_inds)];
% eine Null, dann die Werte aller ueberschwelligen Samples.
% Die Null ist nur noetig, damit aus corresponding_inds auch mit Elementen,
% die nicht innerhalb dieser Matrix liegen
% (weil sie unterschwellig sind), auf diese Matrix verwiesen werden kann
% (indem all diese mit Index = 1 angesprochen werden)

% Index jedes Samples von aseqd innerhalb der reduzierten right_aseqd,
% in der nur ueberschwellige Werte liegen
% Corresponding_inds wird benoetigt, um schnell das Blanking durchfuehren
% zu koennen, und zwar nicht in aseqd, sondern im reduzierten right_aseqd
corresponding_inds=ones(1,nsamp);
% init mit Einsen. Urspruegliche verweisen alle corresponding_inds auf die
% Vorangestellte 0 in right_aseqd
corresponding_inds(right_inds)=2:length(right_inds)+1;						% die herausgepickten Werte erhalten die entsprechenden Indizes
while (dmax(end)>=dmin || i<=nmin+1) && i<=nmax && ~isempty(right_inds)
    if ~isempty(mustContain)
        D(i)=mustContain(1);
        dmax(i)=aseqd(mustContain(1));
        mustContain(1)=[];
        min_dmax=min(min_dmax,dmax(i));
    else
        [dmax(i),new_ind]=max(right_aseqd);
        new_ind=max(1,new_ind-1);
        D(i)=right_inds(new_ind);
    end
    
    % Refraktaer-Bereich ausblenden und im doppelten Ref-Bereich
    % die Amplituden verringern (Penalty-Bereich)
    from_seq=max(1,D(i)-blankdist);
    to_seq=min(D(i)+blankdist,nsamp);
    from_blank=1+ from_seq-(D(i)-blankdist);
    to_blank=nblank- (D(i)+blankdist-to_seq);
    right_aseqd(corresponding_inds(from_seq:to_seq))=...
        right_aseqd(corresponding_inds(from_seq:to_seq)).*...
        blank_func(from_blank:to_blank)';
    i=i+1;
    if i>nmin && isfinite(Tmax)												% falls nargin<6 ist Tmax = inf -> keine max. Pausen
        % DH 2002-10-24  nmin erhoehen, falls zwar >nmin Events gefunden,
        % aber noch sehr lange Pausen ohne Events vorhanden
        if max(diff(sort(D)))>Tmax, nmin=i; end
    end
end


% 2) Anzahl der det. Events < min. anzahl an Events: ----------------------
%	 -> Weitersuchen auch im unterschwelligen Bereich
if i<nmin
    % es wurden mit obiger Methode nicht genuegend Events gefunden
    % -> reset und mit alter Meth. nochmal probieren.
    % Blanking uebernehmen (auch in den unterschwelligen Regionen!)
    for i=1:length(D)
        from_seq=max(1,D(i)-blankdist);
        to_seq=min(D(i)+blankdist,nsamp);
        from_blank=1+ from_seq-(D(i)-blankdist);
        to_blank=nblank- (D(i)+blankdist-to_seq);
        aseqd(from_seq:to_seq)=...
            aseqd(from_seq:to_seq).*...
            blank_func(from_blank:to_blank)';
    end
    i=length(D)+1;
    % DH 2002-10-24 eine Pause von mehr als 3x der max. (f. die ges. Sequenz)
    % mittleren Periodendauer ist nicht zulaessig
    % DH 2002-11-11 nach sig_det ausgelagert,
    % da fuer hsm- und ice-Files nicht sinnvoll (dort kein Tmax)
    % Tmax=length(aseqd)/nmin*3;
    while (dmax(end)>=dmin || i<=nmin+1) && i<=nmax
        [dmax(i),D(i)]=max(aseqd);
        from_seq=max(1,D(i)-blankdist);
        to_seq=min(D(i)+blankdist,nsamp);
        from_blank=1+ from_seq-(D(i)-blankdist);
        to_blank=nblank- (D(i)+blankdist-to_seq);
        aseqd(from_seq:to_seq)=...
            aseqd(from_seq:to_seq).*...
            blank_func(from_blank:to_blank)';												% ausblenden
        i=i+1;
        if i>nmin && isfinite(Tmax)
            % DH 2002-10-24  nmin erhoehen, falls zwar >nmin Events gefunden,
            % aber noch sehr lange Pausen ohne Events vorhanden
            if max(diff(sort(D)))>Tmax, nmin=i; end
        end
    end
end
if length(find(dmax==0))>1
    Z=find(dmax==0);														% falls sehr niedrige Absolutschwelle, kann Sequenz völlig platt sein
    dmax(Z)=[]; D(Z)=[];													% löschen
end
if isempty(dmax)															% keine Es übrig, z.B leerer Kanal
    bsp_warn('det_pick: empty channel - so quitting!');
    return;
end
if 0 && i>nmin+1 && dmax(end)<dmin											% notwendige Mindestanzahl bereits erreicht und letztes unterschwellig
    dmax(end)=[]; D(end)=[];													% loeschen
    % darf nicht geloescht werden, da sonst starker Abfall
    % nicht erkannt werden koennte (z.B. paf/n/n02c.dat)
end


% DHa - Sortieren ausgeremet, weil
%	a) dmax ohnehin fast durchgehend sortiert ist
%	b) lediglich die (schon vom vorigen Fenster mituebergebenen)
%	mustContain-Events unsortiert sind, und diese im Fall von Fehler im
%	vorigen Fenster das aktuelle Fenster voellig irritieren koennen
%	c) die Werte der mustContain-Indizes nicht genau sind, weil sie von
%	einem anderen Kanal kommen koennen und dann nicht genau auf den Zacken
%	liegen
% [dmax,order]=sort(dmax,2,'descend');
% D=D(order);


% 3) Berechnung der Amplituden-Quantifizierung eingeführt -----------------
%	 Bei der Berechnung des stärksten Abfalls all jene Stellen
%	 ausgeschlossen, wo der Abfall nur einen Amplituden-Quant beträgt
%	 wg. Sign. sele210.dat
differences=diff(aseqd);
differences=differences(abs(differences)>0.0000001);						% nur Eintraege ~= 0
amp_quant=min(abs(differences));											% Minimaler Ampl.-Unterschied zw. 2 Samples in Signal
if amp_quant
    diff_dmax=abs(diff(dmax))-amp_quant;									% Unterschied von genau 1 Quantisierungsschritt wird als ident angesehen
    inds=find(diff_dmax>0.000001);											% alle Eintraege mit groesserem Unterschied
    % DHa 2015-11-09 Wie oben: mustContain-Events werden zwar geblankt,
    % aber nicht fuer die Sprung-Bestimmung herangezogen.
    % 	inds=inds(find(dmax(inds)<=min_dmax));									% Sicherstellen, dass die mustContain-Events erhalten bleiben
    if max(inds)>=nmin
        inds=inds(inds>=nmin & inds<=nmax);									% Zumindest nmin werden immer genommen, aber maximal nmax
    else inds=max(inds);
    end
    diff_dmax=diff_dmax(inds);
    L_d=length(diff_dmax);
else
    L_d=[];
    diff_dmax=abs(diff(dmax));
    inds=1:length(diff_dmax);
end


% 4) Maximalen Abfall bestimmen -------------------------------------------
%	 Daraus resultierend die Events und dd als Mass fuer die Deutlichkeit
%	 der Detektion
n_not_sel=0;
iqr_qrs=1;
if L_d
    try
        test_seq=diff_dmax./dmax(inds);											% relativ zu unterem wert des sprungs
        n_max_no_blank=ceil(2*length(aseqd)/ length(blank_func)-nmin);
        if length(test_seq)>n_max_no_blank && n_max_no_blank > 0
            test_seq(n_max_no_blank:end)=test_seq(n_max_no_blank:end)/3;
        end
        [dd,I]=min(-test_seq);													% staerkster Abfall
        if length(test_seq) > 1
            test_sorted=sort(test_seq);												% fuer Qualit: Nicht nur Hoehe diese Sprungs, sondern auch Vergleich
            dd=test_sorted(end-1)-test_sorted(end);									% zu naechst deutlichestem Sprung beruecksichtigen
        end
        
        highest_non_qrs = dmax(inds(I));
        detectspikes = dmax(inds(I)+1);
        
        if (shall_resolve_ds ~= 0)
            lowest_qrs = dmax(inds(I));
            highest_nonqrs = dmax(inds(I)+1);
        else
            lowest_qrs = 0;
            highest_nonqrs = 0;
        end
        I=inds(I);
        % GSc 2017-08-13 - extend cut-off search with GINI concept to
        % capture e.g. extrasystoles with smaller amplitued and derivative
        % search for first point beyond I where gini starts to rise
        for i=1:numel(D)
            G(i)=ginicoeff(diff(sort(D(1:i))));
        end
        Gdiff=diff(G);
        I_min_diff=min(find(Gdiff(I:end)>0));
        [~,I_max_diff]=max(Gdiff(I:end));
        [Gmax,I_Gmax]=max(G);
        [Gmin,I_Gmin]=min(G(I_Gmax:end));
        I_Gmin=I_Gmin+I_Gmax-1;
        searchIndex=[max(5,I-10):min(I+10,length(G))];
        [Gmin4,I_Gmin4]=min(G(searchIndex));
        if I_Gmin4==1 | I_Gmin4==length(searchIndex) % borderline
            I_gini4=I;
        else
            I_gini4 = searchIndex(1)+I_Gmin4-1;
        end
        if ~isempty(I_min_diff)
            I_gini1=I+I_min_diff-1;
        else
            I_gini1=I;
        end
        if ~isempty(I_max_diff)
            I_gini7=I+I_max_diff-1;
        else
            I_gini7=I;
        end
        %            doGini=4
        res_det.Gmax=Gmax;
        res_det.I_Gmax=I_Gmax;
        res_det.Gmin=Gmin;
        res_det.I_Gmin=I_Gmin;
        res_det.I_delta_G_D=I-I_Gmin;

        cutOffText=['\',int2str(doGini)];
        switch doGini
            case 0 % no gini involved, default
                I_cutOff = I;
            case 1 % the minimum of (the minimum of the GINI and the maximum step)
                I_cutOff=min(I_gini1,I_Gmin);
            case 2 % the maximum of (the minimum of the GINI and the maximum step)
                I_cutOff=max(I_gini1,I_Gmin);
            case 3 % just the minimum of the GINI curve
                I_cutOff = I_Gmin;
            case 4 % the local minimum in the vicinity of the maximum step decline
                I_cutOff = I_gini4;
            case 5 % the local minimum in the vicinity of the maximum step decline
                I_cutOff = max(I_gini4,I);
            case 6 % include some additional events to be scrutinized later on
                I_cutOff = max(I_gini4,I)+2;
            case 7 % include some additional events to be scrutinized later on
                I_cutOff = I_gini7;
            case 8 % differentiate between 3 cases
                if res_det.I_delta_G_D == 0
                    I_cutOff = I_gini7;
                elseif res_det.I_delta_G_D < 0
                    I_cutOff = max(I_gini4,I);
                else
                    I_cutOff = max(I_gini4,I);
                end
        end
        if 0
            fh=findobj('Tag','gini');
            if ishandle(fh)
                figure(fh)
            else
                figure('Tag','gini');
            end
            plot(dmax*10,'b'), hold on
            plot(diff(dmax)*10);
            plot(G)
            plot(diff(G)*5,'-.')
            plot(diff(diff(G))*5,'-.')
            grid on
            line(I,dmax(I)*10,'Marker','*','Color','k');
            text(I,dmax(I)*10,'/I','HorizontalAlignment','left','VerticalAlignment','bottom');
            line(I_gini1,G(I_gini1),'Marker','*','Color','k');
            text(I_gini1,G(I_gini1),'/g1','HorizontalAlignment','left','VerticalAlignment','bottom');
            line(I_Gmin,G(I_Gmin),'Marker','*','Color','k');
            text(I_Gmin,G(I_Gmin),'/Gmin','HorizontalAlignment','Left','VerticalAlignment','bottom');
            line(I_gini4,G(I_gini4),'Marker','*','Color','k');
            text(I_gini4,G(I_gini4),'/g4','HorizontalAlignment','left','VerticalAlignment','bottom');
            plot(I_cutOff,G(I_cutOff),'or');
            text(I_cutOff,G(I_cutOff),cutOffText,'HorizontalAlignment','left','VerticalAlignment','Top','Color','r');
            legend({'dmax*10','diff_dmax*10','GINI','dGINI*5','ddGINI*5'});
            hold off
            %            ginput();
        end
        
        if doGini
            I = I_cutOff;
        end
        dlist=sort(D(1:I));														% GS 2001-04-14 V->N
        n_not_sel=length(D)-length(dlist);
        iqr_qrs=iqr(aseqd(dlist));
        if ~isempty(dlist)
            qrs_range = arcs_range(aseqd(dlist))/min(aseqd(dlist));
        else
            qrs_range=inf;
        end
    catch
        a=1;
        qrs_range=inf;
    end
    %   dlist=sort(D(1:Nmin+I));
    
else
    lowest_qrs = 0;
    highest_nonqrs = 0;
    qrs_range=inf;
    % alte Methode
    L=length(dmax);
    if L>1
        Nmin=max(nmin,1);
        Nmax=min(nmax,L-1);
        test_seq=diff(dmax)./dmax(1:L-1);									% relativ
        [dd,I]=min(test_seq(Nmin:Nmax));									% stärkster Abfall
        dd=dd/10;															% "Poenale" fuer verwenden der alten Methode
        
        if (shall_resolve_ds ~= 0)
            lowest_qrs = dmax(I + Nmin -1);
            highest_nonqrs = dmax(I + Nmin);
        else
            lowest_qrs = 0;
            highest_nonqrs = 0;
        end
        
        dlist=sort(D(1:Nmin+I-1));											% GS 2001-04-14 V->N
        
        if isempty(I)
            dd=0;
            lowest_qrs=0;
            highest_nonqrs=0;
        end
        %   dlist=sort(D(1:Nmin+I));
    elseif L																% ein einziges Ereignis und das überschwellig
        dlist=D;
    end
end

