clear; format short;

%%
% §sec:placebo_test -- placebo test on 1996-2000 (no real benefit extensions),
% regressing quasi-differenced unemployment on an ARTIFICIAL placebo benefit
% measure built from a hypothetical extension trigger. Reads output/factor_inputs/Placebo/
% (code/exporters/OutputDataSetsUIMacro_Placebo.do). With nowks=1, RunFactorModel takes
% the FIRST regressor from column exo_var_1 (the placebo benefit) instead of logwks:
%   LHS  = qdk1_logunemp_rate_laus      (QBLS col 5, var_ind 5)
%   RHS  = diff_pwks_*_13               (QBLS col 6..13, exo_var_1 = iiii+5)
% Loop iiii=1..8 = {u4,u5,u6,u7,sa4,sa5,sa6,sa7} triggers, 13-wk extension.
% The PAPER's reported placebo = sa6 (3-mo avg state SA urate > 6%) = iiii=7
% (col 12) -> coef ~0.008, p ~0.35. Window 1996-2000 via drop=24 / trunc=56.
%
% Output SaveDir/SenseResultsPlacebo.csv: 8 cols (one per trigger spec), rows =
% [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs]. Full draws ->
% Placebo_<iiii>_boot.csv. (The 1996-2001 footnote variant 0.015 is the same with
% trunc=52: Factor_FrontEnd_Placebo2001.m.)

config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;

seed=15;
quarterly=1;
factors_to_run_base=[6 5 4 3 2 1];
perfect_foresight=0;

rand('seed',seed) %#ok<RAND>

T=100;
p = 1;
splitwks = 0;
placebo=0;
fixedloadings=0;
inc_constant = 0;
exo_var_2=1; exo_var_3=1; exo_var_4=1; exo_var_5=1;
exorange=1;

SepMethod = 'Placebo';
N = importdata([InputBaseDir SepMethod '/N.txt']);

distresults = zeros(8, 8);

for iiii=1:8
    nowks=1;                 % regressor = exo1 (placebo benefit), not logwks
    p=1;
    var_ind=5;               % LHS = qdk1_logunemp_rate_laus
    exo_var_1=iiii+5;        % placebo benefit column (6..13)
    T=100;
    drop=24;                 % start 1996
    trunc=56;                % end 2000  (1996-2000 = 20 quarters)
    varoi=['placebo_' int2str(iiii)];   % filename/label tag (per-spec)

    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    distresults(:,iiii) = [
        beta_est(1,1);
        sum(sbeta_est(:,1)>0)/nrun*100;
        sbeta_est(round(0.025*nrun),1);
        sbeta_est(round(0.975*nrun),1);
        std(sbeta_est(:,1));
        numfactors;
        (1-ssr/ssy);
        Nobs ];

    cd(SaveDir)
    dlmwrite(['Placebo_' int2str(iiii) '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['Placebo spec ' int2str(iiii) ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsPlacebo.csv', distresults);
cd(FactorModelCodeDir)
