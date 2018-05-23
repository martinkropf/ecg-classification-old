function split_signals()
[data_dir,signal_dir]=getLocalProperties();


% fid_a = fopen('answers_a.txt','w');
% fid_b = fopen('answers_b.txt','w');

files = dir('/Users/mk/Desktop/untitled folder/*.hea');



for file = files'
     filename=strcat(file.folder, filesep, file.name(1:end-4));
     disp(filename);
     %sigdata(filename);
     ecg=rdsamp(file.name(1:end-4));
     ecg=ecg(:,1);
     fs=128;
     dt = 1/fs;
     N = size(ecg,1);
     t = dt*(0:N-1)';

     target_fs=300; 
     ECG_resampled=resample(ecg,t,target_fs)';
     
     window_length=60;
     
     windows = 1:window_length*target_fs:length(ECG_resampled);
     sprintf('Splitting %s into %d parts of %d sec length: ', filename, length(windows), window_length)
     for i=1:length(windows)
     %for i=1:10

         window_start=windows(i);
         window_end=windows(i)+window_length*fs;
         if window_end<length(ECG_resampled)
             samples=ECG_resampled(window_start:window_end);
         else
             samples=ECG_resampled(window_start:length(ECG_resampled));
         end
             name=strcat(file.name(1:end-4),'_',num2str(i));
             mat2wfdb(samples',name,target_fs,16,'mV',[],[], {'ECG1'});
             wfdb2mat(name);
             delete(strcat(name,'.hea')); 
             delete(strcat(name,'.dat')); 
     
             disp('ignore last window');
         
         
     end
     

%      delete(strcat(file.name(1:end-4),'m.mat'));     %complete MAT file;
%      delete(strcat(file.name(1:end-4),'m.hea'));     %complete HEA file;


end
% fclose(fid_a);
% fclose(fid_b);
%create annotations
%files=(dir('*.mat')); for i=1:length(files) disp(strcat(files(i).name(1:end-4),',A')); end

end
