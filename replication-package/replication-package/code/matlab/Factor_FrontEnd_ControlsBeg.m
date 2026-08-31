clear; format short;


%%
% ControlsBeg is the qdsbk1 counterpart of the Controls pairing.
% Reads the same output/factor_inputs/Controls/QBLS*.txt (the exporter was
% extended to write qdsbk1_logunemp_rate_laus as col 19) and runs Col 10
% of paper tab:Benefits_on_unemp_beg -- benefits + 9 state-policy controls.
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


SepMethod='Controls';	% Pick differencing method
quarterly=1;		% 1 for quarterly, 0 for monthly

factors_to_run_base=[6 5 4 3 2 1];

nowks=0;

perfect_foresight=0;

%%

rand('seed',seed) %#ok<RAND>

if(quarterly==1)
    T=100;
else
    T=276;
end

p = 1;
splitwks = 0;
nowks = 0;
drop = 0;
trunc = 0;
placebo=0;
fixedloadings=0;
inc_constant = 0;
exo_var_1=1;
exo_var_2=1;
exo_var_3=1;
exo_var_4=1;
exo_var_5=1;
exorange=1;
counteri=1;

%%
N = importdata([InputBaseDir SepMethod '/N.txt']);

%% Col 10 of Beg table: benefits + 9 state policy controls, qdsbk1 LHS at QBLS col 19
% exorange=6:14 picks the same 9 GDP-normalized controls as the Controls pairing.
p=10;
exorange=6:14;
varoi='qdsbk1_unemp'; %#ok<*NASGU>
var_ind=19;
T=100;
drop=60;
trunc=8;
RunFactorModel;

numfactors=factors_to_run(optfac);
nrun=200;
clusterborder=1;
T=100;
RunPValsFactor_newbs_v4_nowks;
distresults(:,counteri)=[beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1);sbeta_est(round(0.975*nrun),1);std(sbeta_est(:,1));numfactors;(1-ssr/ssy);Nobs];
counteri=counteri+1;

% Col 10 has 10 coefficients (benefits + 9 controls); save the full bootstrap
% summary for all of them. Row 1 = benefits; rows 2..10 are the 9 controls in
% QBLS column order 6..14 (same order as the qdk1 Controls pairing).
controls_summary = zeros(p, 5);
for j=1:p
    controls_summary(j,:) = [beta_est(1,j), sum(sbeta_est(:,j)>0)/nrun*100, sbeta_est(round(0.025*nrun),j), sbeta_est(round(0.975*nrun),j), std(sbeta_est(:,j))];
end
dlmwrite([SaveDir 'ControlsBeg_qdsbk1_unemp_summary.csv'], controls_summary);

cd(SaveDir)
dlmwrite('SenseResultsControlsBeg.csv',distresults);
cd(FactorModelCodeDir)
