function noise_res=isnoise_cinc2017(ecg,QRS,QRS2,classes,...
	avbeats,types,amps,qrs_widths,atrial_ecg,fs,pars)

	nan_inds=find(~isfinite(classes));
	noise_res.ratioNaN=length(nan_inds)/length(classes)*100;
	QRS2(nan_inds)=[];
	classes(nan_inds)=[];

    % GSc 2017-06-04 - new parameter total rms in the hope this heps to
    % catch noisy signals
    noise_res.overallRMS=rms(ecg);
    
	max_sig_amp=pars.isnoise.max_sig_amp;
	max_sig_diff=pars.isnoise.max_sig_diff;
	qrs_amp_range=pars.isnoise.qrs_amp_range;
	qrs_width_range=pars.isnoise.qrs_width_range;

	b_spikes1=pars.isnoise.b_spikes1;
	a_spikes1=pars.isnoise.a_spikes1;
	b_spikes2=pars.isnoise.b_spikes2;
	a_spikes2=pars.isnoise.a_spikes2;
	
	% Irregularity of QRS complexes - do not remove NaN QRSs 
	% (other than for AF)
	bcis=diff(QRS2)/fs;
	rrs=60./bcis;
	median_rr=median(rrs);
	noise_res.rr_irregularity_noise=iqr(rrs)/median_rr;
	noise_res.rr_irregularity_noise2=length(find(abs(rrs-median_rr)>10))/length(rrs)*100;
	
	% Irregularity based on CinC QRS Detector
	bcis=diff(QRS)/fs;
	rrs=60./bcis;
	median_rr=median(rrs);
	noise_res.rr_irregularity_cinc=iqr(rrs)/median_rr;
	noise_res.rr_irregularity2_cinc=length(find(abs(rrs-median_rr)>10))/length(rrs)*100;
	
	nsamp=length(ecg);
	
	noise_res.beats_found_per_second_cinc=length(QRS)/(nsamp/fs);
	noise_res.max_pause_cinc=max(diff([1,QRS,nsamp]))/fs;

	% Schaut der AV-Beat der häufigsten Klasse schön aus?
	for i=1:2
		if ~isempty(avbeats) && isfield(avbeats,'seq') && length(avbeats.seq)>=i &&...
				~isempty(avbeats.window{i}) && length(avbeats.seq{i})>10
			avbeat=avbeats.seq{i};
			win=avbeats.window{i};

			highpass_avbeat=filtfilt(pars.isnoise.high1_b,pars.isnoise.high1_a,avbeat);
			ratio_avbeat_constant=...
				length(find(highpass_avbeat<max(avbeat)/10))/length(highpass_avbeat)*100;

			lowpass_avbeat=filtfilt(pars.isnoise.low_b,pars.isnoise.low_a,avbeat);
			diffs=lowpass_avbeat-avbeat;
			diffs=diffs-mean(diffs);
			ratio_avHighFreq=length(find(abs(diffs)>range(avbeat)/20))/length(avbeat)*100;

			highpass_avbeat=filtfilt(pars.isnoise.high2_b,pars.isnoise.high2_a,avbeat);
			qrs_inds=-win(1)+(round(-0.07*fs):round(0.07*fs));
			qrs_inds=qrs_inds(qrs_inds>0 & qrs_inds<=length(avbeat));
			if isempty(qrs_inds)
				av_qrs_amp=0;
				rest_amp_range=0;
				av_qrs_rest_ratio=0;
			else
				av_qrs_amp=range(highpass_avbeat(qrs_inds));
				rest_amp_range=range(highpass_avbeat(setdiff(1:length(avbeat),qrs_inds)));
				if isempty(rest_amp_range)
					rest_amp_range=-1;
				end
				av_qrs_rest_ratio=av_qrs_amp/rest_amp_range*100;
			end

			if i==2
				% Ähnlichkeit der beiden avbeats bestimmen
				avbeat1=avbeats.seq{1};
				n=min(length(avbeat1),length(avbeat));
				if n>0
					noise_res.av12corr=corr(avbeat(1:n),avbeat1(1:n));
				else
					noise_res.av12corr=0;
				end
			end
		else
			ratio_avbeat_constant=NaN;
			ratio_avHighFreq=NaN;
			av_qrs_rest_ratio=NaN;
			noise_res.av12corr=NaN;
		end
		noise_res.(['ratio_avbeat_constant_',int2str(i)])=ratio_avbeat_constant;
		noise_res.(['ratio_avHighFreq_',int2str(i)])=ratio_avHighFreq;
		noise_res.(['av_qrs_rest_ratio_',int2str(i)])=av_qrs_rest_ratio;
	end

	% std(atrial_ecg):std(ecg)
	noise_res.atrial_ratio=std(ecg)/std(atrial_ecg);
	c_hist=hist(classes,unique(classes(~isnan(classes))));
	noise_res.n_classes_1_beat=length(find(c_hist==1));

	% Wie fuer QRS2 auch bei QRS Rand-QRS loeschen
	QRS(QRS<fs*0.05)=[];
	QRS(QRS>length(ecg)-0.05*fs)=[];

	% HR basierend auf nQRS / nsamp
	noise_res.mean_HR=60*length(QRS2)/(nsamp/fs);
	noise_res.mean_HR_cinc=60*length(QRS)/(nsamp/fs);

	% max. QRS-Pause
	noise_res.max_pause=max(diff([1,QRS2,length(ecg)]))/fs;
	noise_res.max_pause_cinc=max(diff([1,QRS,length(ecg)]))/fs;

	% Konstante Samples
	constant_samples=find(diff(abs(diff(ecg))) == 0);
	constant_samples=find(diff(constant_samples)==0);
	noise_res.ratio_constant=length(constant_samples)/nsamp*100;

	% Samples mit zu gr Amp
	samples_outof_amprange=find(abs(ecg) > max_sig_amp);
	noise_res.ratio_samples_outof_amp=length(samples_outof_amprange)/nsamp*100;

	% QRS-Komplexe mit unpassender Amp
	noise_res.ratio_qrs_outof_amp=length(find(amps<qrs_amp_range(1)|amps>qrs_amp_range(2)))/length(amps)*100;

	% QRS-Komplexe mit unpassender Width
	noise_res.ratio_qrs_outof_width=length(find(qrs_widths<qrs_width_range(1)|qrs_widths>qrs_width_range(2)))/length(amps)*100;

	% Spikes
	diff_out_of_th=double(abs(diff(filtfilt(b_spikes1,a_spikes1,ecg))) > max_sig_diff);
	diff_out_of_th=filtfilt(b_spikes2,a_spikes2,diff_out_of_th);
	samples_outof_diffrange=find(diff_out_of_th > max_sig_diff * 0.1);
	noise_res.ratio_spikes=length(samples_outof_diffrange)/nsamp*100;

	% Sig-Amp in unterschiedlichen Fr-Baendern
	fr=pars.isnoise.fr;
	for i=1:length(fr)-1
		fseq=filtfilt(pars.isnoise.b{i},pars.isnoise.a{i},ecg);
		p_freq(i)=std(fseq);
		p_freq_rel(i)=	p_freq(i)/	p_freq(1);
		eval(['noise_res.p_freq_rel_',int2str(i),'=p_freq_rel(i);']);
	end

	% Kombi der obigen Kriterien - wird nicht mehr verwendet 
	right_samples=1:nsamp;
	right_samples=setdiff(right_samples,constant_samples);
	right_samples=setdiff(right_samples,samples_outof_amprange);
	right_samples=setdiff(right_samples,samples_outof_diffrange);
	noise_res.ratio_ok=length(right_samples)/nsamp*100;

	% Vergleich der 2 QRS-Dets
	AIT_res_not_found_by_template=ones(size(QRS2));
	n_template_res_not_found_by_AIT=0;
	for i=1:length(QRS)
		right_ind=find(abs(QRS2-QRS(i))<0.07*fs);
		if isempty(right_ind)
			n_template_res_not_found_by_AIT=n_template_res_not_found_by_AIT+1;
		else
			AIT_res_not_found_by_template(right_ind)=0;
		end
	end
	n_AIT_res_not_found_by_template=length(find(AIT_res_not_found_by_template));
	noise_res.ratio_qrs_different=...
		(n_template_res_not_found_by_AIT+n_AIT_res_not_found_by_template)/...
		max(length(QRS),length(QRS2))*100;


	% fh=figure; plot(ecg); line(QRS, ecg(QRS), 'Linestyle','none','Marker','*','Color','r');
	% hold on; plot((1:length(avbeat))*20,avbeat-1);
	% y_max=max(ecg); y_min=min(ecg);
	% text(5000,-0.00*(y_max-y_min),['ratio ok: ',num2str(noise_res.ratio_ok)]);
	% text(5000,-0.05*(y_max-y_min),['qrs different: ',num2str(noise_res.ratio_qrs_different)]);
	% text(5000,-0.10*(y_max-y_min),['p freq: ',num2str(noise_res.p_freq_rel)]);
	% text(5000,-0.15*(y_max-y_min),['ratio spikes: ',num2str(noise_res.ratio_spikes)]);
	% text(5000,-0.20*(y_max-y_min),['qrs width: ',num2str(noise_res.ratio_qrs_outof_width)]);
	% text(5000,-0.25*(y_max-y_min),['qrs amp: ',num2str(noise_res.ratio_qrs_outof_amp)]);
	% text(5000,-0.30*(y_max-y_min),['samples amp: ',num2str(noise_res.ratio_samples_outof_amp)]);
	% text(5000,-0.35*(y_max-y_min),['av constant: ',num2str(noise_res.ratio_avbeat_constant)]);
	% text(5000,-0.40*(y_max-y_min),['hr mean: ',num2str(noise_res.mean_HR)]);
	% text(5000,-0.45*(y_max-y_min),['max pause: ',num2str(noise_res.max_pause)]);
	% text(5000,-0.50*(y_max-y_min),['n SC n = 1: ',num2str(noise_res.n_classes_1_beat)]);
	% text(5000,-0.55*(y_max-y_min),['av high: ',num2str(noise_res.ratio_avHighFreq)]);
	% text(5000,-0.60*(y_max-y_min),['av qrs ratio: ',num2str(noise_res.av_qrs_rest_ratio)]);
	% text(5000,-0.70*(y_max-y_min),['total: ',num2str(noise_res.sum_factor)]);
	% text(5000,-0.75*(y_max-y_min),['total: ',num2str(noise_res.n_over_th)]);
	% 
	% 
	% keyboard;
	% delete(fh);
