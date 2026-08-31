clear; format short;


%%


config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


SepMethod='Bench';	% Pick differencing method
quarterly=1;		% 1 for quarterly, 0 for monthly
N=1172;				% Set to number of pairs

%N=72;
%N=22;
factors_to_run_base=[6 5 4 3 2 1];
%factors_to_run_base=[2];

run_unemp=0;		% run unemployment
run_unemp_count=0;	% run unemployment

run_laus_emp=0;	% run laus emp (bls)
run_qcew_emp=0; % run qcew emp
run_qwi_emp=0;	% run qwi_emp (beg. of quarter)
run_qwi_end=0;	% run qwi_emp (end of quarter)
run_qwi_s=0;	% run qwi_emp (stable)
run_qwi_avg=0;	% run qwi_emp (average)
run_qwi_tot=0;	% run qwi_emp (total)
run_vacrate=0;	% run V/L
run_newvac=0;	% run new V/L
run_newhirrate=0;
run_totalhirrate=0;
run_wage_stayers=0; %wages of stayers, DiD
run_tight=0;	% run tightness
run_ttilde=0;	% run tightness
run_utilde=0;	% run tightness
run_x=0;
run_manu=0;
run_manu_share=0;
run_food=0;
run_food_share=0;
run_retail=0;
run_retail_share=0;
run_w=0;
run_ent=0;
nowks=0;

perfect_foresight=0;

run_prod_diff=0;	% State prod on RHS, diff
run_prod_qdiff=0;	% State prod on RHS, qdiff
% exo_var_1=1;
% exo_var_2=1;
%%

rand('seed',seed) %#ok<RAND>

if(quarterly==1)
%    T=100;
    T=100;
%    T=96;
%    T=100;
%    T=89;
else
    T=276;
%    T=96;
end

p = 1;
splitwks = 0;
nowks = 0;
drop = 0;
trunc = 0;
placebo=0;
fixedloadings=0;
inc_constant = 0;
exo_var_1=1; % 9;
exo_var_2=1; %10;
exo_var_3=1;
exo_var_4=1;
exo_var_5=1;
exorange=1;
counteri=1;

%%
SepMethod='Bench';	% Pick differencing method
N = importdata([InputBaseDir SepMethod '/N.txt']);

%% Col 1: baseline (QD unemployment on benefits, all pairs)
p=1;
varoi='qd1_unemp'; %#ok<*NASGU>
var_ind=5;
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
varoi='qd1_unemp_prodall'; %#ok<*NASGU>
var_ind=5;
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
dlmwrite([SaveDir 'Bench_qd1_unemp_prodall_summary.csv'], prodall_summary);

%% Col 9: perfect-foresight benefits (diff_logmeanwks_pf at QBLS col 8 as RHS)
p=1;
nowks=1;
exo_var_1=8;
exorange=1;
varoi='qd1_unemp_pf'; %#ok<*NASGU>
var_ind=5;
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
dlmwrite('SenseResultsBench.csv',distresults);
cd(FactorModelCodeDir)
