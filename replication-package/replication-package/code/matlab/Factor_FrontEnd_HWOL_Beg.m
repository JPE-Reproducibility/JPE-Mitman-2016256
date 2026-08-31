clear; format short;

%%
% tab:macroeffects_beg -- Vacancies + Tightness columns (HWOL vacancy IFE,
% QWI-separation "beg" quasi-difference). QWI-separation analog of
% Factor_FrontEnd_HWOL.m: reads output/factor_inputs/HWOL_Beg/ (from
% code/exporters/OutputDataSetsUIMacro_HWOL_Beg.do), same QBLS column layout but the LHS
% are qdsbk1_ (QWI-beg separation) quasi-differences:
%   Vacancies  = qdsbk1_logvacrate2  (QBLS col 7, var_ind 7)  -- paper Col (1)
%   Tightness  = qdsbk1_logtight2    (QBLS col 5, var_ind 5)  -- paper Col (2)
% p=1, drop60/trunc8, PC factor selection + 200-rep clustered bootstrap.
%
% *** VACANCY-GATED *** (uses the proprietary vacancy data). Output
% SaveDir/SenseResultsHWOL_Beg.csv: col 1 Vacancies, col 2 Tightness; rows =
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

SepMethod = 'HWOL_Beg';
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
    dlmwrite(['HWOL_Beg_' lhs_names{c} '_boot.csv'], sbeta_est);
    cd(FactorModelCodeDir)

    disp(['HWOL_Beg ' lhs_names{c} ' done; beta_b=' num2str(beta_est(1,1)) ...
          ', numfactors=' num2str(numfactors) ', Nobs=' num2str(Nobs)]);
end

cd(SaveDir)
dlmwrite('SenseResultsHWOL_Beg.csv', distresults);
cd(FactorModelCodeDir)
