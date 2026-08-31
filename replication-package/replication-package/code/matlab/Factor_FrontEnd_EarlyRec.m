clear; format short;

%%
% §sec:literature / secular-decline paragraph (~L1277). Re-runs the paper's
% MAIN benchmark specification (quasi-differenced county unemployment on benefit
% weeks, interactive fixed effects) on EARLIER recession windows, to show the
% effect of benefit extensions was larger in earlier recessions than in the Great
% Recession (consistent with a secular decline in responsiveness):
%   "...the 1991 recession (using the 1990-1996 sample) ... coefficient ... 0.072
%    with a p-value of 0. Repeating the analysis using the data on benefit
%    extensions during the 2001 recession (the 1996-2005 sample) yields a
%    coefficient ... 0.062 with a p-value of 0. ... larger than our estimate of
%    0.053 using the later data from the Great Recession period."
%
% Same Bench QBLS export
% (code/exporters/OutputDataSetsUIMacro_Bench.do -> output/factor_inputs/Bench/) as Table 1
% Col 1; only the analysis WINDOW changes via drop/trunc. Each pair's QBLS series
% is 1990q1-2014q4 (100 quarters); RunFactorModel uses rows drop+1 : end-trunc:
%   drop=0,  trunc=72 -> positions 1..28  = 1990q1-1996q4  (1991 recession)
%   drop=24, trunc=36 -> positions 25..64 = 1996q1-2005q4  (2001 recession)
%   drop=60, trunc=8  -> positions 61..92 = 2005q1-2012q4  (Great Recession; the
%                                            0.053 benchmark, included as an anchor)
% Benchmark spec: nowks=0 (first regressor = logwks = diff_logmeanwks, QBLS col 4),
% LHS = qdk1_logunemp_rate_laus (var_ind 5), p=1, single regressor, no controls.
%
% Output SaveDir/SenseResultsEarlyRec.csv: 3 cols (rec1991, rec2001, GRcheck), rows
% = [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs]. Full draws ->
% EarlyRec_<tag>_boot.csv.

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
counteri=1;

SepMethod='Bench';
N = importdata([InputBaseDir SepMethod '/N.txt']);

% windows: {tag, drop, trunc} -> rec1991, rec2001, Great-Recession anchor
windows = {'rec1991', 0, 72; 'rec2001', 24, 36; 'GRcheck', 60, 8};
distresults = zeros(8, size(windows,1));

for counteri=1:size(windows,1)
    tag   = windows{counteri,1};
    drop  = windows{counteri,2};
    trunc = windows{counteri,3};

    p=1;
    nowks=0;
    var_ind=5;                 % LHS = qdk1_logunemp_rate_laus
    T=100;
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
    dlmwrite(['EarlyRec_' tag '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['EarlyRec ' tag ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', %>0=' num2str(sum(sbeta_est(:,1)>0)/nrun*100) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsEarlyRec.csv', distresults);
cd(FactorModelCodeDir)
