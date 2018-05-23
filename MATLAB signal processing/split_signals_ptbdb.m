function split_signals_ptbdb()
[data_dir,signal_dir]=getLocalProperties();


% fid_a = fopen('answers_a.txt','w');
% fid_b = fopen('answers_b.txt','w');



dirinfo = dir('/Users/mk/cinc2017/Datasets/ptbdb/');
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories

subdirinfo = cell(length(dirinfo));
for K = 1 : length(dirinfo)
  thisdir = dirinfo(K).name;
  subdirinfo{K} = dir(fullfile(thisdir, '*.dat'));
end




for file=3:length(subdirinfo)
     info=subdirinfo(file);
     info=info{1,1};
     
     for i=1:size(info,1)
         name=info(i).name;
         folder=info(i).folder;
         filename=strcat(folder, filesep, name);
         disp(filename);
         cd(folder);
         wfdb2mat(filename(1:end-4));
         [tm,ecg,fs,siginfo]=rdmat(strcat(filename(1:end-4),'m'));
         ecg=ecg(:,1);
         dt = 1/fs;
         N = size(ecg,1);
         t = dt*(0:N-1)';

        target_fs=300; 
        ECG_resampled=resample(ecg,t,target_fs)';
     
        window_length=60;
     
        windows = 1:window_length*fs:length(ECG_resampled);
        sprintf('Splitting %s into %d parts of %d sec length: ', filename, length(windows), window_length)
        for part=1:1
             window_start=windows(part);
             window_end=windows(part)+window_length*fs;
             if window_end<length(ECG_resampled)
                 samples=ECG_resampled(window_start:window_end);
                 name=strcat(filename,'_',num2str(part));
                 mat2wfdb(samples',name,target_fs,16,'mV',[],[], {'ECG1'});
                 wfdb2mat(name);
                 disp(name);
                 delete(strcat(name,'.hea')); 
                 delete(strcat(name,'.dat')); 
             else
                 disp('ignore last window');
             end
        end
     

     end
     
     %filename=strcat(file.folder, filesep, file.name(1:end-4));
    
%      delete(strcat(file.name(1:end-4),'m.mat'));     %complete MAT file;
%      delete(strcat(file.name(1:end-4),'m.hea'));     %complete HEA file;


end
% fclose(fid_a);
% fclose(fid_b);
%create annotations
%files=(dir('*.mat')); for i=1:length(files) disp(strcat(files(i).name(1:end-4),',A')); end

end
