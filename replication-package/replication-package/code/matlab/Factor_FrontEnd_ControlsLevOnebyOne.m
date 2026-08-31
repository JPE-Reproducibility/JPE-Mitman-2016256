clear; format short;


%%
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

%%
N = importdata([InputBaseDir SepMethod '/N.txt']);

%% Appendix Levels one-by-one: stimulus_taxes Cols 2–5 (Variable in Levels)
% iiii→variable mapping (exorange=iiii+14, reading the 4 Levels cols 15-18):
%   iiii=1 col 15 diff_logawardamount   → appendix stimulus_taxes Col 2 (Stimulus, Levels)
%   iiii=2 col 16 diff_logtotal         → appendix stimulus_taxes Col 3 (Total Tax, Levels)
%   iiii=3 col 17 diff_logincome        → appendix stimulus_taxes Col 5 (Income Tax, Levels)
%   iiii=4 col 18 diff_loggeneral_sales → appendix stimulus_taxes Col 4 (Sales Tax, Levels)
distresults = zeros(8,4);          % standard 8-stat layout for the benefits coef per iteration
controls_only_summary = zeros(4,5); % control coef stats per iteration

for iiii=1:4
    p=2;
    exorange=iiii+14;
    varoi=['qd1_unemp_ControlsLev_' int2str(iiii)]; %#ok<*NASGU>
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

    distresults(:,iiii) = [beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1); sbeta_est(round(0.975*nrun),1); std(sbeta_est(:,1)); numfactors; (1-ssr/ssy); Nobs];
    controls_only_summary(iiii,:) = [beta_est(1,2), sum(sbeta_est(:,2)>0)/nrun*100, sbeta_est(round(0.025*nrun),2), sbeta_est(round(0.975*nrun),2), std(sbeta_est(:,2))];
end

cd(SaveDir)
dlmwrite('SenseResultsControlsLevOnebyOne.csv', distresults);
dlmwrite('Controls_LevOnebyOne_controls_summary.csv', controls_only_summary);
cd(FactorModelCodeDir)
