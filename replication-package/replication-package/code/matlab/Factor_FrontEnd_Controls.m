clear; format short;


%%
config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;


seed=15; %Set the seed
drop=60;		% 0 to start in 2002, increase forward from then
trunc=0;   %number of observations to cut off the end


SepMethod='Controls';	% Pick differencing method
quarterly=1;		% 1 for quarterly, 0 for monthly

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
counteri=1;

%%
N = importdata([InputBaseDir SepMethod '/N.txt']);

%% Col 10 of Table 1: benefits + 9 state policy controls
% exorange=6:14 picks all 9 controls in QBLS column order:
%   col 6  diff_logawardamount_gdp     ARRA stimulus spending / state GDP
%   col 7  diff_sbsi                   State Business Survival Index
%   col 8  diff_sbtc                   State Business Tax Climate Index
%   col 9  diff_bhi                    BHI State Competitiveness Index
%   col 10 diff_logtotal_gdp           total state tax revenue / state GDP
%   col 11 diff_logincome_gdp          state income tax revenue / state GDP
%   col 12 diff_loggeneral_sales_gdp   state sales tax revenue / state GDP
%   col 13 diff_judicial               judicial foreclosure dummy
%   col 14 diff_bbce_asset2018         SNAP broad-based categorical eligibility (asset test)
p=10;
exorange=6:14;
varoi='qd1_unemp'; %#ok<*NASGU>
var_ind=5;
T=100;
drop=60;
trunc=8;
RunFactorModel;

numfactors=factors_to_run(optfac);
nrun=200;			%number of bootstrap replications
clusterborder=1;
T=100;
RunPValsFactor_newbs_v4_nowks;
distresults(:,counteri)=[beta_est(1,1); sum(sbeta_est(:,1)>0)/nrun*100; sbeta_est(round(0.025*nrun),1);sbeta_est(round(0.975*nrun),1);std(sbeta_est(:,1));numfactors;(1-ssr/ssy);Nobs];
counteri=counteri+1;

% Col 10 has 10 coefficients (benefits + 9 controls); save the full bootstrap
% summary for all of them. Row 1 = diff_logmeanwks (benefits); rows 2..10 are
% the 9 controls in QBLS column order 6..14 (diff_logawardamount_gdp, diff_sbsi,
% diff_sbtc, diff_bhi, diff_logtotal_gdp, diff_logincome_gdp,
% diff_loggeneral_sales_gdp, diff_judicial, diff_bbce_asset2018).
% Cols: [coef, %>0 in bootstrap, 2.5% pct, 97.5% pct, std]
controls_summary = zeros(p, 5);
for j=1:p
    controls_summary(j,:) = [beta_est(1,j), sum(sbeta_est(:,j)>0)/nrun*100, sbeta_est(round(0.025*nrun),j), sbeta_est(round(0.975*nrun),j), std(sbeta_est(:,j))];
end
dlmwrite([SaveDir 'Controls_qd1_unemp_summary.csv'], controls_summary);

cd(SaveDir)
dlmwrite('SenseResultsControls.csv',distresults);
cd(FactorModelCodeDir)
