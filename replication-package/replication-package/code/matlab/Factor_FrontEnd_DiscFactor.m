clear; format short;

%%
% Discount-factor robustness footnote (§baseline_results, ~L780). Re-estimates the
% benchmark with the 1-period quasi-difference built at beta = 0.9975 and 0.98 (vs the
% standard 0.99) and reports the permanent effect alpha_hat/(1-beta(1-s)). Point
% estimates only -- the footnote reports no p-values.
%
% Reads output/factor_inputs/DiscFactor/ (OutputDataSetsUIMacro_DiscFactor.do), which
% recomputes the quasi-difference at each beta. Same benchmark window/spec as Table 1
% Col 1 (p=1, nowks=0, benefit = diff_logmeanwks at col 4, drop=60/trunc=8 = 2005q1-2012q4).
%   var_ind 5 = qd_b9975  (beta=0.9975)
%   var_ind 6 = qd_b98    (beta=0.98)
%   var_ind 7 = qdk1_logunemp_rate_laus (beta=0.99 anchor; reproduces Col 1 -> perm 0.488)
%
% NOTE: the permanent effect rises monotonically with beta (0.484 @0.98, 0.488 @0.99,
% 0.491 @0.9975), bracketing the benchmark 0.488. The substantive conclusion (the
% discount factor is immaterial for the permanent effect) is unchanged.
%
% Output SaveDir/SenseResultsDiscFactor.csv: rows = beta, alpha_hat, permanent_effect,
% numfactors, Nobs (one row per beta: 0.9975, 0.98, 0.99).

config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;

seed=15;
quarterly=1;
factors_to_run_base=[6 5 4 3 2 1];
perfect_foresight=0;
rand('seed',seed) %#ok<RAND>

T=100;
p=1; splitwks=0; nowks=0; placebo=0; fixedloadings=0; inc_constant=0;
exo_var_1=1; exo_var_2=1; exo_var_3=1; exo_var_4=1; exo_var_5=1; exorange=1;

SepMethod='DiscFactor';
N = importdata([InputBaseDir SepMethod '/N.txt']);

s = 0.10;                                  % avg quarterly separation rate
specs = [5 0.9975; 6 0.98; 7 0.99];        % [var_ind, beta]
out = zeros(size(specs,1), 5);

for k=1:size(specs,1)
    var_ind = specs(k,1);
    bta     = specs(k,2);
    p=1; nowks=0; T=100; drop=60; trunc=8;
    varoi=['disc_b' num2str(round(bta*10000))];

    RunFactorModel;

    a    = beta_est(optfac,1);
    perm = a/(1-bta*(1-s));
    out(k,:) = [bta, a, perm, factors_to_run(optfac), Nobs];
    disp(['DiscFactor beta=' num2str(bta) ' alpha=' num2str(a) ...
          ' perm=' num2str(perm) ' numfac=' num2str(factors_to_run(optfac))]);
end

cd(SaveDir)
dlmwrite('SenseResultsDiscFactor.csv', out);
cd(FactorModelCodeDir)
