clear; format short;

%%
% Appendix §app:data_quality_claims (~L2125). Effect of benefit extensions on the
% job-finding rate of UI claimants, backed out of BLS administrative claims data, vs.
% the same effect measured with LAUS unemployment on the identical claims sample.
% Paper:
%   "...the coefficient alpha_f = -0.0486, with a p-value of 0.03. ... alpha_f(1-u) ~=
%    -alpha_u ... with u = 7.01% we get alpha_u = 0.0452. Using instead LAUS county
%    unemployment ... on this sample we find ... 0.0475, with a p-value of 0."
%
% Same benchmark spec / window /
% standard RunFactorModel as Table 1 Col 1 (p=1, nowks=0, benefit regressor =
% diff_logmeanwks at QBLS col 4, drop=60/trunc=8 -> 2005q1-2012q4); only the LHS
% changes. The quasi-differenced job-finding rates are PRE-BUILT in DataControls (the
% build backs the monthly rate out of continuing-claims + final-payments via the
% eq:claims recursion and merges it), exported by OutputDataSetsUIMacro_JFR.do.
% Only the two REPORTED specs are run; the three unreported job-finding clamps
% (f_cl/f_cl2/f_cl_q) were pruned from the build, exporter, and here. The exporter's
% missing-filter is unchanged in effect (same 282 pairs), so the numbers below are intact.
% QBLS columns / var_ind:
%   5 qdk1_logunemp_rate_laus   LAUS unemployment, this sample -> alpha_u  0.0475 (p 0)
%   6 qdk1_logf_cl2_q           quarterly-compounded cl2 job-finding -> alpha_f -0.0486 (p 0.03)
% Sample = ~282 pairs / 9,024 obs.
%
% Output SaveDir/SenseResultsJFR.csv: 2 cols (unemp, f_cl2_q),
% rows = [coef; %>0; 2.5pct; 97.5pct; std; numfactors; R^2; Nobs]. Full draws ->
% JFR_<tag>_boot.csv.

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

SepMethod='JFR';
N = importdata([InputBaseDir SepMethod '/N.txt']);

% {tag, var_ind}: the two reported specs -- LAUS unemployment (alpha_u) and the
% quarterly-compounded cl2 job-finding rate (alpha_f). (f_cl2_q is now QBLS col 6.)
specs = {'unemp', 5; 'f_cl2_q', 6};
distresults = zeros(8, size(specs,1));

for counteri=1:size(specs,1)
    tag     = specs{counteri,1};
    var_ind = specs{counteri,2};

    p=1;
    nowks=0;
    T=100;
    drop=60;                  % start 2005q1
    trunc=8;                  % end 2012q4 (positions 61..92; claims sample 9,024 obs)
    varoi=['jfr_' tag];

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
    dlmwrite(['JFR_' tag '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['JFR ' tag ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', %>0=' num2str(sum(sbeta_est(:,1)>0)/nrun*100) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsJFR.csv', distresults);
cd(FactorModelCodeDir)
