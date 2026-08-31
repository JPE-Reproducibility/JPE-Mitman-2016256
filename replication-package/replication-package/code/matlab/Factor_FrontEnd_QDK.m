clear; format short;


%%
% Forward_Spec / tab:Forward_Spec front-end. Loops k=1..8, fitting the
% interactive-effects model with k-period-ahead quasi-differenced unemployment
% on the LHS and benefits at periods t, t+1, ..., t+k-1 on the RHS. Writes
% per-k point-estimate and bootstrap-distribution CSVs that ProcessQDK.m
% consumes to compute the permanent-effect and hypothesis-test statistics
% that populate paper tab:Forward_Spec.
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;
trunc=0;


quarterly=1;

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

%% Loop k=1..8.
% QBLS column mapping (set in OutputDataSetsUIMacro_QDK.do):
%   col 4         diff_logmeanwks      (benefits at t)
%   col 4+k       qdk{k}_logunemp_rate_laus
%   cols 13..11+k f1..f_{k-1}_logmeanwks (future benefits to include as regressors)
SepMethod = 'QDK';
N = importdata([InputBaseDir SepMethod '/N.txt']);

distresults = zeros(8, 8);

for iiii=1:8
    p=iiii;
    var_ind=4+iiii;
    trunc=8+iiii-1;
    drop=60;
    T=100;
    varoi=['qd' int2str(iiii) '_unemp_new']; %#ok<*NASGU>

    if iiii==1
        % k=1 has no benefit leads; only the current-period benefit at col 4.
        % Use a harmless placeholder for exorange so RunFactorModel can read it
        % into exovars (the value is never consumed because p=1).
        exorange = 4;
    else
        exorange = 13:11+iiii;
    end

    RunFactorModel;

    numfactors=factors_to_run(optfac);
    nrun=200;
    clusterborder=1;
    T=100;
    RunPValsFactor_newbs_v4_nowks;

    % distresults: standard 8-row layout for the FIRST regressor (current-period
    % benefits). Permanent-effect and aggregate-of-leads statistics are
    % computed by ProcessQDK.m from QDK{k}boot.csv (full bootstrap matrix).
    distresults(:,iiii) = [
        beta_est(1,1);
        sum(sbeta_est(:,1)>0)/nrun*100;
        sbeta_est(round(0.025*nrun),1);
        sbeta_est(round(0.975*nrun),1);
        std(sbeta_est(:,1));
        numfactors;
        (1-ssr/ssy);
        Nobs ];

    % Save the FULL bootstrap distribution for this k (rows = bootstrap reps,
    % cols = regressors b_t, b_{t+1}, ..., b_{t+k-1}). ProcessQDK reads this
    % to compute permanent effects and hypothesis-test statistics.
    cd(SaveDir)
    dlmwrite(['QDK' int2str(iiii) 'boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['QDK k=' int2str(iiii) ' done; beta_b=' num2str(beta_est(1,1)) ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsQDK.csv', distresults);
cd(FactorModelCodeDir)
