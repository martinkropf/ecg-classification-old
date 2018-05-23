function ccs = arcs_corcoefvec(x)
% ccs = arcs_corcoef_vec(x)
%
% DH
%
% berechnet den Korrelation-Koeffizienten des ersten Vektors in x mit 
% jedem weiteren Vektor in x
% x muss bereits offset-Korrigiert sein (um mean(x) fuer jeden Vektor)

x_sq = x.^2;
var_q = sum(x_sq(:,:));
cov_q = x(:,1:end-1)'*x(:,end);
ccs = cov_q'./sqrt(var_q(1:end-1).*var_q(end));
