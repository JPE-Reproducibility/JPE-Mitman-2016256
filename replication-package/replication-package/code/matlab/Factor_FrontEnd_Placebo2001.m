clear; format short;

%%
% §sec:placebo_test footnote -- placebo test extended to 1996-2001. Identical to
% Factor_FrontEnd_Placebo.m except the window: trunc=52 (vs 56) extends the sample
% by four quarters to 1996-2001.
% The paper's footnote spec = sa6 (iiii=7) -> coef ~0.015 (marginally significant).
% Reads output/factor_inputs/Placebo/ (same export as the 2000 run).
%
% Output SaveDir/SenseResultsPlacebo2001.csv (8 cols; rows = [coef;%>0;2.5;97.5;
% std;numfactors;R^2;Nobs]); full draws -> Placebo2001_<iiii>_boot.csv.

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
    nowks=1;
    p=1;
    var_ind=5;
    exo_var_1=iiii+5;
    T=100;
    drop=24;                 % start 1996
    trunc=52;                % end 2001  (1996-2001 = 24 quarters)
    varoi=['placebo2001_' int2str(iiii)];   % filename/label tag (per-spec)

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
    dlmwrite(['Placebo2001_' int2str(iiii) '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['Placebo2001 spec ' int2str(iiii) ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsPlacebo2001.csv', distresults);
cd(FactorModelCodeDir)
