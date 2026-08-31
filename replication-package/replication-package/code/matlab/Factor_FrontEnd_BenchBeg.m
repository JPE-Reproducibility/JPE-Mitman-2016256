clear; format short;


%%
% BenchBeg is the qdsbk1 counterpart of the Bench pairing. It reads the same
% output/factor_inputs/Bench/QBLS*.txt files (the exporter was extended to write
% qdsbk1_logunemp_rate_laus as col 9) and runs the same Cols 1, 2, 9
% sub-experiments of the paper -- but with the QWI-beginning-of-quarter
% quasi-difference as the LHS instead of the JOLTS-rate quasi-difference.
% Produces paper tab:Benefits_on_unemp_beg Cols 1, 2, and 9.
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


SepMethod='Bench';	% Pick differencing method (shares QBLS files with the qdk1 Bench)
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

%% Col 1: baseline (QD-Beg unemployment on benefits, all pairs)
p=1;
varoi='qdsbk1_unemp'; %#ok<*NASGU>
var_ind=9;
T=100;
drop=60;
trunc=8;
RunFactorModel;

numfactors=factors_to_run(optfac);
nrun=200;			%number of bootstrap replications
clusterborder=1;
T=100;
RunPValsFactor_newbs_v4_nowks;
distresults(:,counteri)=[beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1);sbeta_est(round(0.975*nrun),1);std(sbeta_est(:,1));numfactors;(1-ssr/ssy);Nobs];
counteri=counteri+1;

%% Col 2: + State GDP per Worker control (diff_logprod_all at QBLS col 7)
p=2;
exorange=7;
varoi='qdsbk1_unemp_prodall'; %#ok<*NASGU>
var_ind=9;
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

% Col 2 has two coefficients; save the full bootstrap summary for both.
% Row 1 = diff_logmeanwks (benefits); row 2 = diff_logprod_all (State GDP per Worker).
% Cols: [coef, %>0 in bootstrap, 2.5% pct, 97.5% pct, std]
prodall_summary = [ ...
    beta_est(1,1), sum(sbeta_est(:,1)>0)/nrun*100, sbeta_est(round(0.025*nrun),1), sbeta_est(round(0.975*nrun),1), std(sbeta_est(:,1)); ...
    beta_est(1,2), sum(sbeta_est(:,2)>0)/nrun*100, sbeta_est(round(0.025*nrun),2), sbeta_est(round(0.975*nrun),2), std(sbeta_est(:,2)) ];
dlmwrite([SaveDir 'BenchBeg_qdsbk1_unemp_prodall_summary.csv'], prodall_summary);

%% Col 9: perfect-foresight benefits (diff_logmeanwks_pf at QBLS col 8 as RHS)
p=1;
nowks=1;
exo_var_1=8;
exorange=1;
varoi='qdsbk1_unemp_pf'; %#ok<*NASGU>
var_ind=9;
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

cd(SaveDir)
dlmwrite('SenseResultsBenchBeg.csv',distresults);
cd(FactorModelCodeDir)
