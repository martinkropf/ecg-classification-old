function ecg=lead_inversion(ecg,fs,pars,recNr)


%% Get Averaged Beat
[QRS2,amps,qrs_widths,qrs_res]=detectevents_cinc2017(ecg,fs,pars);
classes=corrclass_cinc2017(ecg,QRS2,fs,pars.corrclass.scw1,pars.corrclass.ccmin1);
[av_res,avbeats]=avbeat_cinc2017(ecg,QRS2,classes,fs,pars);
right_av_ind=avbeats.SC==1;
av_window=avbeats.window{right_av_ind};
av_seq=avbeats.seq{right_av_ind};
% av_peaks=findpeaksx(1:length(av_seq),av_seq,0.0001,0.01,1,2,3);
% subplot(2,1,1), plot(av_seq);
% n_peaks_av=size(av_peaks,1);

QRS_window=pars.detectaf.av_qrswave_window;
qrsseq_avbeat=av_seq(max(1,-av_window(1)+round(QRS_window(1)*fs)):-av_window(1)+round(QRS_window(2)*fs));
% QRS=findpeaksx(1:length(qrsseq_avbeat),qrsseq_avbeat,0.0001,0.01,1,2,3);


T_window=pars.detectaf.av_twave_window;
tseq_avbeat=av_seq(max(1,-av_window(1)+round(T_window(1)*fs)):end);

% subplot(2,1,2), plot(tseq_avbeat);
% T=findpeaksx(1:length(tseq_avbeat),tseq_avbeat,0.0001,0.01,1,2,3);

t_negative=0;
qrs_negative=0;

diff_max_qrs=abs(max(qrsseq_avbeat)-mean(qrsseq_avbeat));
diff_min_qrs=abs(min(qrsseq_avbeat)-mean(qrsseq_avbeat));
if (diff_min_qrs>diff_max_qrs)
%     disp(['Negative QRS: ', num2str(recNr)]);
    qrs_negative=1;
end

diff_max_t=abs(max(tseq_avbeat)-mean(tseq_avbeat(1:end)));
diff_min_t=abs(min(tseq_avbeat)-mean(tseq_avbeat(1:end)));
if (diff_min_t>diff_max_t)
%     disp(['Negative T: ', num2str(recNr)]);
    t_negative=1;
end

if (qrs_negative==1 && t_negative==1)
    disp(['Invert signal: ', num2str(recNr)]);
    ecg=ecg*-1;
%     inverted=1;
end