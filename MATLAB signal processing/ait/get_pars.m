function pars=get_pars(fs)

pars.pars2ignore={...
'P_corr_iqrMaxDist',...
'P_corr_medianMaxDist',...
'P_corr_nConstant_rel',...
'P_corr_nCrossZero_rel',...
'P_corr_nExtrema_rel',...
'P_corr_ratioInDeCreases',...
'P_rmsav_iqrMaxDist',...
'P_rmsav_medianMaxDist',...
'P_rmsav_nConstant_rel',...
'P_rmsav_nCrossZero_rel',...
'P_rmsav_nExtrema_rel',...
'P_rmsav_ratioInDeCreases',...
'P_rmszero_iqrMaxDist',...
'P_rmszero_medianMaxDist',...
'P_rmszero_nConstant_rel',...
'P_rmszero_nCrossZero_rel',...
'P_rmszero_nExtrema_rel',...
'P_rmszero_ratioInDeCreases',...
'QRS_iqrMaxDist',...
'QRS_medianMaxDist',...
'QRS_nConstant_rel',...
'QRS_nCrossZero_rel',...
'QRS_nExtrema_rel',...
'QRS_ratioInDeCreases',...
'af_distMean2multipleRR',...
'af_distMean2multipleRR1',...
'af_distMedian2multipleHR',...
'af_distMedian2multipleHR1',...
'af_firstPeakAmp_iqrMaxDist',...
'af_firstPeakAmp_iqrMaxDist1',...
'af_firstPeakAmp_medianMaxDist',...
'af_firstPeakAmp_medianMaxDist1',...
'af_firstPeakAmp_ratioInDeCreases',...
'af_firstPeakAmp_ratioInDeCreases1',...
'af_firstPeakDist_iqrMaxDist',...
'af_firstPeakDist_iqrMaxDist1',...
'af_firstPeakDist_medianMaxDist',...
'af_firstPeakDist_medianMaxDist1',...
'af_firstPeakDist_ratioInDeCreases',...
'af_firstPeakDist_ratioInDeCreases1',...
'af_maxPeakAmp_iqrMaxDist',...
'af_maxPeakAmp_iqrMaxDist1',...
'af_maxPeakAmp_medianMaxDist',...
'af_maxPeakAmp_medianMaxDist1',...
'af_maxPeakAmp_ratioInDeCreases',...
'af_maxPeakAmp_ratioInDeCreases1',...
'af_maxPeakDist_iqrMaxDist',...
'af_maxPeakDist_iqrMaxDist1',...
'af_maxPeakDist_medianMaxDist',...
'af_maxPeakDist_medianMaxDist1',...
'af_maxPeakDist_ratioInDeCreases',...
'af_maxPeakDist_ratioInDeCreases1',...
'af_nFirstPeakAmpExtrema_rel',...
'af_nFirstPeakAmpExtrema_rel1',...
'af_nFirstPeakDistExtrema_rel',...
'af_nFirstPeakDistExtrema_rel1',...
'af_nMaxPeakAmpExtrema_rel',...
'af_nMaxPeakAmpExtrema_rel1',...
'af_nMaxPeakDistExtrema_rel',...
'af_nMaxPeakDistExtrema_rel1',...
'commonPattern_BCI_iqrMaxDist',...
'commonPattern_BCI_medianMaxDist',...
'commonPattern_BCI_nConstant_rel',...
'commonPattern_BCI_nCrossZero_rel',...
'commonPattern_BCI_nExtrema_rel',...
'commonPattern_amp_iqrMaxDist',...
'commonPattern_amp_medianMaxDist',...
'commonPattern_amp_nConstant_rel',...
'commonPattern_amp_nCrossZero_rel',...
'commonPattern_amp_nExtrema_rel',...
'commonPattern_amp_ratioInDeCreases',...
'commonPattern_width_iqrMaxDist',...
'commonPattern_width_medianMaxDist',...
'commonPattern_width_nConstant_rel',...
'commonPattern_width_nCrossZero_rel',...
'commonPattern_width_nExtrema_rel',...
'commonPattern_width_ratioInDeCreases'};

   

pars.add_ws=1;
pars.add_Pres=1;
pars.add_QRSres=1;
pars.add_av=1;
pars.add_af=1;
pars.add_rhythm=1;
pars.add_noise=0;
pars.add_corr=1;
pars.add_qrs=1;
pars.add_inv=0;
pars.add_combined=1;
pars.add_beat=1;
pars.add_remav=1;
pars.add_commonPattern=1;

pars.fs=fs;
pars.blankSecsAtStart=1.5;

pars.doInitialFiltering=0;
pars.detectSpikes = 1;
pars.detectSpikesMethod=0;
pars.detectSpikesPosition=1;

pars.suppressNonAITqrsDetection=0; 
pars.deleteClassesLessThan=0; 
pars.addStandardisedEventTimes=1; 
pars.n_min_for_a_row=5; 
pars.refineQRScorrMin=1.0; 
pars.n_min_for_brady=3;
pars.n_min_for_tachy=4;
pars.tachy_bpm=106;
pars.brady_bpm=43;

pars.corrclass.debugged = 1;

pars.removeaverage.dist=0.055;
pars.removeaverage.filtfreq=20;
pars.removeaverage.lmovav=[-0.3,0.6]*fs;
[pars.removeaverage.b,pars.removeaverage.a]=butter(2,pars.removeaverage.filtfreq*2/fs);		% Filter fuer Blanking

%% checkForLeadInversion
pars.checkForLeadInversion.method=3; % 1...Cinc R/S, 2...P und T Peaks, 3...AIT R/S
pars.checkForLeadInversion.minPeakHeight=0.04;
pars.checkForLeadInversion.minPeakWidth=0.06;
pars.checkForLeadInversion.maxPeakWidth=0.4;
pars.checkForLeadInversion.peakDistMin=0.026;
pars.checkForLeadInversion.QRSblankInterval=0.08;
pars.checkForLeadInversion.amplitudeFactor=1.3;
pars.checkForLeadInversion.addFeatures=0;

%% detectaf
pars.detectaf.spec_order=12;
[pars.detectaf.b,pars.detectaf.a]=butter(1,[1,30]*2/fs); % filter fuer spec berechnung
[pars.detectaf.b2,pars.detectaf.a2]=butter(1,[5,15]*2/fs); % filter fuer spec berechnung
pars.detectaf.winfunc='hamming';
pars.detectaf.winpar=0;
pars.detectaf.spec_methode='music';
pars.detectaf.av_pwave_window=[-0.3,-0.07];
pars.detectaf.av_twave_window=[0.11,0.4];
pars.detectaf.av_qrswave_window=[-0.06,0.06];
pars.detectaf.nice_dur_min=5;
pars.detectaf.nice_bci_diff_max=0.07*fs;
pars.detectaf.atrial_ecg_amp_max=0.5;
pars.detectaf.findOptimalWindow=1;
pars.detectaf.peaksQRSblankInt=0.07;
pars.detectaf.PdoubleInt=0.05;
pars.detectaf.addPfromAV=1;
pars.detectaf.minPeakDistance1=0.05;
pars.detectaf.minPeakDistance2=0.2;

pars.detectaf.fr=[0.001,0.5,1,2,5,10,20];
fr=pars.detectaf.fr;
pars.detectaf.bf={};
pars.detectaf.af={};
for i=1:length(fr)-1
	[pars.detectaf.bf{i},pars.detectaf.af{i}]=butter(2,[fr(i),fr(i+1)]*2/fs,'bandpass');
end

%% avbeat
pars.avbeat.avwindow=[-0.38,0.56];			% [-0.38,0.56] ist optimum
pars.avbeat.preferredStartWindow=[-0.32,-0.20];
pars.avbeat.npointsmin=0.3;					% 0.3 ist optimum
pars.avbeat.rp=0.28;
pars.avbeat.nBeatsOtherRhythmDetectionMin=7;
pars.avbeat.P_dist_ref_max=0.022;
pars.avbeat.instab_factor=5;
pars.avbeat.gradient_factor=2;
pars.avbeat.late_factor=1/10000;
pars.avbeat.ST_candidate_window=[0.05,0.3];
pars.avbeat.QRS_off_th=0.03;
pars.avbeat.setOtherRhythmBeatsEctopic=1;	% bringt selbes Erg wie 0 - koennte aber durch Optimierung von Patterns noch besser werden
pars.avbeat.P_amp_min=0.02;					% funkt am besten
pars.avbeat.P_duration_min=0.03;			% 0.03 ist optimum
pars.avbeat.P_duration_max=0.16;			% optimum
pars.avbeat.searchNegativePwaves=0;
pars.avbeat.checkEctopic=1;
pars.avbeat.checkWPW=2;
pars.avbeat.partOfBCIbeforQRS2look4Pwave=0;

%% corrclass
pars.corrclass.scw1=[-0.075,0.075]; 
pars.corrclass.ccmin1=0.93;
pars.corrclass.scw2=[-0.075,0.075]; 
pars.corrclass.ccmin2=0.985;

%% rhythmclass
pars.rhythmclass.d2Prematurity=0.23; 
pars.rhythmclass.d2Postmaturity=0.375; 
pars.rhythmclass.n_bci_xcreases_in_a_row_max=4; 
pars.rhythmclass.premrel=12;
pars.rhythmclass.premabs=1.3; 
pars.rhythmclass.nnorm=4; 
pars.rhythmclass.maxRationToMedianAmp=1.5; 
pars.rhythmclass.relBCIdiffCouplet=0.1; 
pars.rhythmclass.hr_smooth_factor=0.2;
pars.rhythmclass.hr_diff_regular=6;

pars.rhythm.weight_EV=1;
pars.rhythm.weight_DE=4;
pars.rhythm.weight_ED=7;
pars.rhythm.weight_EVN=1;
pars.rhythm.weight_NEV=7;
pars.rhythm.weight_DNE=7;
pars.rhythm.weight_EDE=15;
pars.rhythm.weight_DED=12;
pars.rhythm.weight_NED=9;
pars.rhythm.weight_EDN=6;
pars.rhythm.weight_NEDE=7;
pars.rhythm.weight_EDNE=7;
pars.rhythm.weight_DNED=6;
pars.rhythm.weight_DEDE=9;
pars.rhythm.weight_EDED=10;
pars.rhythm.weight_NNED=1;
pars.rhythm.weight_NEDN=1;

pars.rhythm.weight_2letters=1;
pars.rhythm.weight_3letters=1;
pars.rhythm.weight_4letters=1;
pars.rhythm.weight_1x1x=3;
pars.rhythm.weight_1x1x1x=10;
pars.rhythm.weight_N1N1=1/5;
pars.rhythm.weight_N1N1N1=1/5;
pars.rhythm.weight_nPatternSum=1;


%% detectevents
pars.detectevents.dmin=0.0002; 
pars.detectevents.nmin=40; 
pars.detectevents.nmax=165; 
[pars.detectevents.b,pars.detectevents.a]=butter(2,[11,20]/fs*2,'bandpass');
[pars.detectevents.b2,pars.detectevents.a2]=butter(2,[20,30]/fs*2,'bandpass');
[pars.detectevents.filt_FP_b,pars.detectevents.filt_FP_a]=butter(2,[4,25]*2/fs,'bandpass');
pars.detectevents.doGini=0;

arp=0.15*fs;
rrp=0.225*fs;
pars.detectevents.blank_func=[1:-1/rrp:0,zeros(1,2*arp-1),0:1/rrp:1];

pars.detectevents.fpw=[-0.05,0.05];
pars.detectevents.distBorderMin=0.05;
pars.detectevents.allow2ndRun=1;		% 1 ist besser


%% isnoise
pars.isnoise.max_sig_amp=2;
pars.isnoise.max_sig_diff=0.5*128/fs;
pars.isnoise.qrs_amp_range=[0.2,2];
pars.isnoise.qrs_width_range=[0.025,0.12];
[pars.isnoise.b_spikes1,pars.isnoise.a_spikes1]=butter(2, [30,70]*2/fs,'stop');
[pars.isnoise.b_spikes2,pars.isnoise.a_spikes2]=butter(2, 10*2/fs, 'low');
[pars.isnoise.high1_b,pars.isnoise.high1_a]=butter(2,20*2/fs,'high');
[pars.isnoise.high2_b,pars.isnoise.high2_a]=butter(2,4*2/fs,'high');
[pars.isnoise.low_b,pars.isnoise.low_a]=butter(2,[15]*2/fs,'low');
pars.isnoise.fr=[0.001,0.5,1,10,20,50,100];
fr=pars.isnoise.fr;
pars.isnoise.b={};
pars.isnoise.a={};
for i=1:length(fr)-1
	[pars.isnoise.b{i},pars.isnoise.a{i}]=butter(2,[fr(i),fr(i+1)]*2/fs,'bandpass');
end

%% beatParameters
pars.beatParameters.Pwindow=[-0.3,-0.05];
pars.beatParameters.QRSwindow=[-0.07,0.07];
pars.beatParameters.rp=0.28;
pars.version='V37';