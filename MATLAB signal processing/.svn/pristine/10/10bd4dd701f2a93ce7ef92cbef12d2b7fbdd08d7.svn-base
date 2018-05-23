function win_func=get_win_func(n,func,par)

func=lower(func);
switch func
	case 'rectangle'
		win_func=rectwin(n);
	case 'triangle'
		win_func=triang(n);
	case 'barthmann'
		win_func=barthannwin(n);
	case 'bartlett'
		win_func=bartlett(n);
	case 'blackman'
		win_func=blackman(n);
	case 'blackmanharris'
		win_func=blackmanharris(n);
	case 'bohman'
		win_func=bohmanwin(n);
	case 'cheb'
		win_func=chebwin(n,par);
	case 'gauss'
		win_func=gausswin(n);
	case 'hamming'
		win_func=hamming(n);
	case 'hann'
		win_func=hann(n);
	case 'kaiser'
		win_func=kaiser(n,par);
	case 'nuttall'
		win_func=nuttallwin(n);
	case 'tukey'
		win_func=tukeywin(n,par);
	otherwise
end

