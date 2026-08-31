clear; format short;

%%
% tab:macroeffects_beg -- Employment column (QCEW employment IFE, QWI-separation
% "beg" quasi-difference). QWI-separation analog of Factor_FrontEnd_EmpQCEW.m:
% reads output/factor_inputs/EmpQCEW_Beg/ (code/exporters/OutputDataSetsUIMacro_EmpQCEW_Beg.do),
% LHS = qdsbk1_logqcew_emp (QBLS col 5, var_ind 5; 4 factors). p=1, drop60/trunc8,
% PC selection + 200-rep clustered bootstrap.
%
% NOT vacancy-gated -- QCEW county employment is public; fully shippable.
% Output SaveDir/SenseResultsEmpQCEW_Beg.csv: one column, rows =
% [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs].

config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;

seed=15;
quarterly=1;
factors_to_run_base=[6 5 4 3 2 1];
nowks=0;
perfect_foresight=0;

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
exorange=4;

SepMethod = 'EmpQCEW_Beg';
N = importdata([InputBaseDir SepMethod '/N.txt']);

p=1;
var_ind=5;
drop=60;
trunc=8;
T=100;
exorange=4;
varoi='qcewemp'; %#ok<NASGU>

RunFactorModel;

numfactors=factors_to_run(optfac);
nrun=200;
clusterborder=1;
T=100;
RunPValsFactor_newbs_v4_nowks;

distresults = [
    beta_est(1,1);
    sum(sbeta_est(:,1)>0)/nrun*100;
    sbeta_est(round(0.025*nrun),1);
    sbeta_est(round(0.975*nrun),1);
    std(sbeta_est(:,1));
    numfactors;
    (1-ssr/ssy);
    Nobs ];

cd(SaveDir)
dlmwrite('EmpQCEW_Beg_boot.csv', sbeta_est);
dlmwrite('SenseResultsEmpQCEW_Beg.csv', distresults);
cd(FactorModelCodeDir)

disp(['EmpQCEW_Beg done; beta_b=' num2str(beta_est(1,1)) ...
      ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
