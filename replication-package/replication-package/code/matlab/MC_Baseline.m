clear; format short;
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
seed=15; quarterly=1; factors_to_run_base=[2]; perfect_foresight=0; rand('seed',seed)
T=100; p=1; splitwks=0; nowks=0; placebo=0; fixedloadings=0; inc_constant=0;
exo_var_1=1; exo_var_2=1; exo_var_3=1; exo_var_4=1; exo_var_5=1; exorange=1;
SepMethod='Bench'; N=importdata([InputBaseDir SepMethod '/N.txt']);
var_ind=5; drop=60; trunc=8; T=100; varoi='mc_base';
RunFactorModel;
Xb=Xdata(:,:,1); Yb=Ydata; Mb=(M==1); lam=lambda_hat; Fb=F_hat; bet=beta_est(end,1);
[T2,Ncol]=size(Xb);
% 108-segment border id per renumbered pair (col2 of mc_borderid.txt; col1 = pair index)
bid=importdata([InputBaseDir SepMethod '/mc_borderid.txt']);
borderid=zeros(Ncol,1);
for rr=1:size(bid,1), pid=bid(rr,1); if pid<=Ncol, borderid(pid)=bid(rr,2); end; end
[~,~,borderid]=unique(borderid);   % compress to 1..Nborder
bcheck = mc_fixedr(Xb, Yb, 2, Mb);
fprintf('==BASE== beta(RFM)=%.6f beta(mc_fixedr)=%.6f T2=%d N=%d Nborder=%d nMiss=%d\n', ...
  bet, bcheck, T2, Ncol, max(borderid), sum(Mb(:)));
save(fullfile(factor_inputs,'kit_mc_baseline.mat'),'Xb','Yb','Mb','lam','Fb','bet','borderid');
exit
