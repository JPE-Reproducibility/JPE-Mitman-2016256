clear; format short;

%%
% tab:Benefits_on_JobCreation -- Vacancies + Tightness columns (HWOL vacancy IFE).
% Reads output/factor_inputs/HWOL/ (built by code/exporters/OutputDataSetsUIMacro_HWOL.do).
% Two sub-experiments, each with a single regressor (benefit weeks at QBLS col 4),
% drop=60 / trunc=8, Bai-Ng PC factor selection + clustered residual bootstrap --
% exactly the benchmark IFE inference used elsewhere in the kit:
%   Vacancies  = qdk1_logvacrate2  (QBLS col 7, var_ind 7)  -- paper Col (1)
%   Tightness  = qdk1_logtight2    (QBLS col 5, var_ind 5)  -- paper Col (2)
% (The exporter also writes vacrate1/tight1 at cols 8/6; the published table uses
% the "2" variants.)
%
% *** VACANCY-GATED *** (uses the proprietary vacancy data): tight2/vacrate2 embed the
% proprietary HWOL vacancies. Built on the real DataControls vintage this reproduces
% the published numbers; on the synthetic-vacancy DataControls it is demonstrative.
%
% Output SaveDir/SenseResultsHWOL.csv: col 1 = Vacancies, col 2 = Tightness;
% rows = [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs] (the standard
% 8-row distresults layout). Full bootstrap draws -> HWOL_<lhs>_boot.csv.

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
exorange=4;   % placeholder; p=1 so exovars are read but never consumed

SepMethod = 'HWOL';
N = importdata([InputBaseDir SepMethod '/N.txt']);

lhs_inds  = [7 5];                 % col 1 Vacancies (vacrate2), col 2 Tightness (tight2)
lhs_names = {'vacrate2','tight2'};
distresults = zeros(8, numel(lhs_inds));

for c=1:numel(lhs_inds)
    p=1;
    var_ind=lhs_inds(c);
    drop=60;
    trunc=8;
    T=100;
    exorange=4;
    varoi=lhs_names{c}; %#ok<NASGU>

    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    distresults(:,c) = [
        beta_est(1,1);
        sum(sbeta_est(:,1)>0)/nrun*100;
        sbeta_est(round(0.025*nrun),1);
        sbeta_est(round(0.975*nrun),1);
        std(sbeta_est(:,1));
        numfactors;
        (1-ssr/ssy);
        Nobs ];

    cd(SaveDir)
    dlmwrite(['HWOL_' lhs_names{c} '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['HWOL ' lhs_names{c} ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsHWOL.csv', distresults);
cd(FactorModelCodeDir)
