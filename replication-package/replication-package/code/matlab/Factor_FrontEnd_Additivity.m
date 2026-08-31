clear; format short;

%%
% Appendix §app:data_quality_additivity (~L2092). Robustness of the baseline estimate
% to the LAUS "additivity factor" adjustment. LAUS multiplies each county's unemployment
% estimate by a state-specific additivity factor so county unemployment sums to the BLS
% state total; the BLS released those factors to the authors, allowing the adjustment to
% be UNDONE. Re-estimating the baseline (benchmark interactive-effects) specification on
% the additivity-factors-REMOVED unemployment yields:
%   "...the coefficient of 0.054 with p-value of 0.000 on weeks of benefits. Thus, a
%    direct comparison ... before and after the additivity adjustment ... are very similar."
%
% Same Bench pairing as Table 1 Col 1 (same pairs, same benefit regressor diff_logmeanwks,
% same Great-Recession window). ONLY the LHS changes: the additivity-removed quasi-diff
% log unemployment qdk1_logunemp_add, which OutputDataSetsUIMacro_Bench.do now exports as
% QBLS column 10. Spec: nowks=0 (first regressor = logwks = diff_logmeanwks, col 4),
% var_ind=10, p=1, no controls, window drop=60/trunc=8 -> positions 61..92 = 2005q1-2012q4.
% qdk1_logunemp_add is populated 2005-2013 (the additivity factors' coverage), with the
% identical 37,496-obs benchmark sample as the standard LAUS LHS (corr 0.84).
%
% Col 1 = additivity-removed (the paper's 0.054). Col 2 = standard LAUS LHS (var_ind=5)
% on the SAME window as a built-in anchor reproducing the Table 1 Col 1 benchmark 0.053.
%
% Output SaveDir/SenseResultsAdditivity.csv: 2 cols (addremoved, lauscheck), rows =
% [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs]. Full draws ->
% Additivity_<tag>_boot.csv.

config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;

seed=15;
quarterly=1;
factors_to_run_base=[6 5 4 3 2 1];
perfect_foresight=0;

rand('seed',seed) %#ok<RAND>

T=100;
p=1;
splitwks=0;
nowks=0;
placebo=0;
fixedloadings=0;
inc_constant=0;
exo_var_1=1; exo_var_2=1; exo_var_3=1; exo_var_4=1; exo_var_5=1;
exorange=1;

SepMethod='Bench';
N = importdata([InputBaseDir SepMethod '/N.txt']);

% {tag, var_ind}: additivity-removed LHS (col 10), then standard LAUS LHS (col 5) anchor
specs = {'addremoved', 10; 'lauscheck', 5};
distresults = zeros(8, size(specs,1));

for counteri=1:size(specs,1)
    tag     = specs{counteri,1};
    var_ind = specs{counteri,2};

    p=1;
    nowks=0;
    T=100;
    drop=60;                  % start 2005q1
    trunc=8;                  % end 2012q4 (positions 61..92, Great-Recession window)
    varoi=['qd1_unemp_' tag];

    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    distresults(:,counteri) = [
        beta_est(1,1);
        sum(sbeta_est(:,1)>0)/nrun*100;
        sbeta_est(round(0.025*nrun),1);
        sbeta_est(round(0.975*nrun),1);
        std(sbeta_est(:,1));
        numfactors;
        (1-ssr/ssy);
        Nobs ];

    cd(SaveDir)
    dlmwrite(['Additivity_' tag '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['Additivity ' tag ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', %>0=' num2str(sum(sbeta_est(:,1)>0)/nrun*100) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsAdditivity.csv', distresults);
cd(FactorModelCodeDir)
