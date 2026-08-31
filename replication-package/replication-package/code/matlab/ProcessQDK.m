%% Process QDK
% Reads the per-k point estimates and bootstrap distributions written by
% Factor_FrontEnd_QDK.m and computes the permanent-effect / implied
% unemployment statistics that populate paper tab:Forward_Spec, plus the
% hypothesis tests reported in the text around that table (one-sided
% t-tests of each k vs the baseline k=1, an F-test of joint equality, and
% pairwise Wald tests).
clear;
close all;


config;   % sets InputBaseDir, SaveDir, paths (run from code/matlab)
FactorModelCodeDir=pwd;
SepMethod = 'QDK';

N = importdata([InputBaseDir SepMethod '/N.txt']);
nrun=200;

beta_factor = 0.99;     % paper's discount factor
sep_factor  = 0.9;      % 1 - s with quarterly s=0.10
log_ratio   = log(99) - log(26);   % from omega_1=26 -> omega_2=99 weeks
u_eq        = 0.05;     % equilibrium unemployment rate under 26-week benefits

K = 8;
std_perm = zeros(K,1);
std_u    = zeros(K,1);
ci_perm  = zeros(K,2);
ci_u     = zeros(K,2);
point_perm = zeros(K,1);
point_u    = zeros(K,1);
point_u_pct = zeros(K,1);
Nobs_per_k = zeros(K,1);
weeks_coefs = zeros(K, K);   % column k holds the alpha_1..alpha_k vector for that k
perm_mat = zeros(nrun, K);
u_mat    = zeros(nrun, K);

cd(SaveDir)
for k=1:K
    discount = (beta_factor * sep_factor)^k;

    % Bootstrap distribution: nrun x k matrix of (b_t, b_{t+1}, ..., b_{t+k-1})
    beta_coefs = readmatrix(['QDK' int2str(k) 'boot.csv']);

    % Point estimates of the k alpha coefficients
    point = readmatrix(['QDK_qd' int2str(k) '_unemp_new_coefs.csv']);
    weeks_coefs(1:k, k) = point(:);

    % Sample size for this k (from RunFactorModel's Nobs output)
    Nobs_per_k(k) = readmatrix(['QDK_qd' int2str(k) '_unemp_new_Nobs.csv']);

    % Permanent effect: sum(alphas) * log(99/26) / (1 - (beta*(1-s))^k)
    perm_effects = sum(beta_coefs, 2) * log_ratio / (1 - discount);
    implied_u    = exp(perm_effects + log(u_eq));

    std_perm(k)  = std(perm_effects);
    std_u(k)     = std(implied_u);
    ci_perm(k,:) = [perm_effects(round(0.025*nrun)), perm_effects(round(0.975*nrun))];
    ci_u(k,:)    = [implied_u(round(0.025*nrun)),    implied_u(round(0.975*nrun))];

    point_perm(k)   = sum(weeks_coefs(:,k)) * log_ratio / (1 - discount);
    point_u(k)      = exp(point_perm(k) + log(u_eq));
    point_u_pct(k)  = 100 * point_u(k);

    perm_mat(:,k) = perm_effects;
    u_mat(:,k)    = implied_u;
end

%% Pairwise one-sided t-tests of permanent effect: each k vs k=1.
% Bootstrap-derived std of the difference perm(k) - perm(1).
std_perm_diff = zeros(K, 1);
t_stat        = zeros(K, 1);
p_value_t     = zeros(K, 1);
for k=2:K
    diff_dist          = perm_mat(:,k) - perm_mat(:,1);
    std_perm_diff(k)   = std(diff_dist);
    t_stat(k)          = (point_perm(k) - point_perm(1)) / std_perm_diff(k);
    % Paper: one-sided test; report p = 1 - tcdf(t, nrun-k).
    p_value_t(k) = 1 - tcdf(t_stat(k), nrun - k);
end

%% F-test pooling all 8 estimates against their mean.
pooled_var = mean(std_perm.^2);
mean_b     = mean(point_perm);
numerator  = sum((point_perm - mean_b).^2) / (K - 1);
denominator = pooled_var;
f_stat     = numerator / denominator;
df1        = K - 1;
df2        = sum(Nobs_per_k) - K;
F_p_value  = 1 - fcdf(f_stat, df1, df2);

%% Pairwise Wald tests (chi-squared) of each k vs k=1, using the bootstrap
%% covariance of the permanent-effect vector.
V = cov(perm_mat);
b_orig = point_perm;
wald_stats     = zeros(K-1, 1);
chi2_p_values  = zeros(K-1, 1);
for i = 1:(K-1)
    R = zeros(1, K);
    R(1, 1)     = 1;
    R(1, i+1)   = -1;
    diff_pt     = R * b_orig;
    RVR         = R * V * R';
    wald_stats(i)    = diff_pt' / RVR * diff_pt;
    chi2_p_values(i) = 1 - chi2cdf(wald_stats(i), 1);
end

%% Save outputs for make_tables.py / discoveries.
% Forward_Spec_summary.csv: 8 rows x 6 cols
%   [k, Nobs, point_perm, point_u_pct, ci_perm_lo, ci_perm_hi]
summary = [ (1:K)', Nobs_per_k, point_perm, point_u_pct, ci_perm(:,1), ci_perm(:,2) ];
dlmwrite([SaveDir 'Forward_Spec_summary.csv'], summary);

% Forward_Spec_tests.csv: 7 rows x 3 cols (k=2..8)
%   [k, p_value_t (one-sided), chi2_p (pairwise Wald)]
tests = [ (2:K)', p_value_t(2:K), chi2_p_values ];
dlmwrite([SaveDir 'Forward_Spec_tests.csv'], tests);

% Forward_Spec_joint_test.csv: 1 row x 3 cols
%   [f_stat, df1, F_p_value]
dlmwrite([SaveDir 'Forward_Spec_joint_test.csv'], [f_stat, df1, F_p_value]);

disp(' ');
disp('=== Forward_Spec summary ===');
disp(' k    Nobs       perm    impl_u%   ci_perm_lo  ci_perm_hi');
disp([summary]);
disp(' ');
disp('=== Pairwise t-tests vs k=1 (one-sided) ===');
disp(' k    p_t       chi2_p');
disp([tests]);
disp(' ');
disp(['Joint F-test (k=1..8 equal): F=' num2str(f_stat) '  df1=' num2str(df1) '  df2=' num2str(df2) '  p=' num2str(F_p_value)]);

cd(FactorModelCodeDir)
