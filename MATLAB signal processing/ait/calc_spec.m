function [Pxx,f]=calc_spec(seq,method,win_func,order,N,fs);
% [Pxx,f]=calc_spec(seq,method,win_func,order,N,fs);
%
% DH 2004
%
% Berechnet das Spektrum der Sequenz seq
%
% Uebergabeparameter
%	seq			Signalsequenz
%	method		Methode, nach der das Spektrum berechnet wird, als String
%		- 'fourier'		FFT
%		- 'periodogram' Verwendet die periodogram-Funktion von Matlab mit
%				windowing function = []
%		- 'pwelch'		Verwendet pwelch, wobei die Original-Sequenz in 
%				order Teilsequenzen mit Overlab=0.5 unterteilt wird, die
%				jeweil auch noch mit einem Hamming-Fenster gesmoothed
%				werden
%			!! Windowing funktioniert nicht 
%							-> auf order=[], overlap=[] eingeschraenkt !!
%		- 'multitaper'	Verwendet pmtm von Matlab mit
%				time-bandwidth-product = order
%		- 'yule_walker'		pyulear
%		- 'burg'			pburg
%		- 'covariance'		pcov - Covariance Methode
%		- 'mod_covariance'	pmcov - modified Covariance Methode
%		- 'music'			pmusic - MUSIC
%		- 'eigenvector'		peig
%		DEFAULT: 'fourier'
%	win_func	Windowing function 
%		DEFAULT: keines (rectangle)
%	order		nicht verwendet bei 'fourier','periodogram'
%				# Fenster bei pwelch (overlap = 0.5)
%				time-bandwidth-product bei 'multitaper'
%				Ordnung ansonsten
%		DEFAULT: 10
%	N			Anzahl an zu berechnenden FFT-Punkten
%		DEFAULT: length(seq)
%	fs			Abtastrate von seq [Hz]
%		DEFAULT: 1
%
% Rueckgabeparameter
%	Pxx		Spektrale Leistungsdichte [ursprl.Einheit^2 pro Hertz]
%	f		Vektor mit den Frequenzen, an denen Pxx berechnet wurde [Hz]

if nargin<1 || isempty(seq),		
	disp('at least one input argument needed'); 
	return; 
end
if nargin<2 || isempty(method),		method=fourier; end
if nargin<3 || isempty(win_func),	win_func=ones(size(seq)); end
if nargin<4 || isempty(order),		order=10; end
if nargin<5 || isempty(N),			N=length(seq); end
if nargin<6 || isempty(fs),			fs=1; end
order=min(order,length(seq));
if size(seq,1)~=size(win_func,1) && size(seq,1)==size(win_func,2)
	win_func=win_func';
end
seq=seq.*win_func;
switch method
	case 'fourier'
		ft=fft(seq,N);
		Pxx=ft(1:floor(length(ft)/2)).*conj(ft(1:floor(length(ft)/2)))/(N/2)^2;
		f=[1:floor(length(ft)/2)]'*fs/length(ft);
	case 'periodogram'
		[Pxx,f]=periodogram(seq,[],N,fs);
		Pxx=Pxx*fs/length(f);
	case 'pwelch'
		order=[];
		overlap=[];
		[Pxx,f]=pwelch(seq,order,overlap,N,fs);	
		Pxx=Pxx*fs/length(f);
		% order ist die Anzahl an Zeitfenstern, in die die ursprl. seq
		% unterteilt wird
		% derzeit nur mit overlap=0.5 moeglich
	case 'multitaper'
		[Pxx,f]=pmtm(seq,order,N,fs);		
		Pxx=Pxx*fs/length(f);
		% time-bandwidth product = order 
		% Typical choices for NW are 2, 5/2, 3, 7/2, or 4. Default = 4
	case 'yule_walker'
		[Pxx,f]=pyulear(seq,order,N,fs);	
		Pxx=Pxx*fs/length(f);
	case 'burg'
		[Pxx,f]=pburg(seq,order,N,fs);	
		Pxx=Pxx*fs/length(f);
	case 'covariance'
		[Pxx,f]=pcov(seq,order,N,fs);		
		Pxx=Pxx*fs/length(f);
	case 'mod_covariance'
		[Pxx,f]=pmcov(seq,order,N,fs);		
		Pxx=Pxx*fs/length(f);
	case 'music'
		[Pxx,f]=pmusic(seq,[order,1],N,fs);		
		Pxx=Pxx*fs/length(f);												% Vorsicht: Amplituden stimmen bei music und eigenvector nicht
	case 'eigenvector'
		[Pxx,f]=peig(seq,order,N,fs);		
		Pxx=Pxx*fs/length(f);
	otherwise
end
