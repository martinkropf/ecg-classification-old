function export_avbeat()
    signal_dir = '/Users/mk/training2017/';

    reffile = [signal_dir, 'REFERENCE.csv'];
    fid = fopen(reffile, 'r');
    if(fid ~= -1)
        Ref = textscan(fid,'%s %s','Delimiter',',');
    else
        error(['Could not open ' reffile ' for scoring. Exiting...'])
    end
    fclose(fid);
    
    RECORDS = Ref{1};
    target  = Ref{2};

    %load avbeat
  
    fid = fopen('avbeats.txt','w');

    for i = 1:length(RECORDS)
    
     
        if mod(i,100)==0
            disp(['processing record ',int2str(i),'/',int2str(length(RECORDS))]);
        end
        fname = RECORDS{i};
        [tm,ecg,fs,siginfo]=rdmat(['/Users/mk/training2017/',fname]);
        mat2wfdb(ecg,fname,fs,16,'V',[],[],   {'ECG1'});

        length_ecg(i)=length(ecg);
        pars=get_pars(300);
        [QRS2,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg,fs,pars);
        RR=diff(QRS2')/fs;
        
        RR_resampled=resample(ecg,60,length(ecg));
        %size(RR_resampled)
        classes=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
        avbeats=avbeat_cinc2017(ecg,QRS2,classes,fs,pars);
        avbeat_seq=avbeats.seq{1,1};
        
        save(['/Users/mk/training2017/avbeats/',fname,'.mat'],'avbeats','-mat')

%         ecg_resampled=resample(ecg,3000,length(ecg));
%         fourier=calc_spec(ecg,'fourier');
%         fourier_resampled=resample(fourier,250,length(fourier));
%         avbeat_resampled=resample(avbeat_seq,256,length(avbeat_seq));

        allOneString = sprintf('%.4f,' , avbeat_seq);
        allOneString = allOneString(1:end-1);% strip final comma
        allOneString=strrep(allOneString,',,',',');

        if strcmp(target{i,:},'N')
            answer=1;
        elseif strcmp(target{i,:},'A')
            answer=2;
        elseif strcmp(target{i,:},'O')
            answer=3;            
        elseif strcmp(target{i,:},'~')
            answer=4;
        end
        fprintf(fid,'%d,%s\r\n',answer,allOneString);
        
   
  
        
    end
    fclose(fid);

end
