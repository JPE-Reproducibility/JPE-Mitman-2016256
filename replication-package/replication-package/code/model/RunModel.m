% =========================================================================
% RunModel.m  ->  tab:valid (Model row) + calibration-moment check
%
% Structural model section (paper \S sec:simulation). The equilibrium search
% model (Mortensen-Pissarides with UI benefit expiration; den Haan-Ragan-Sargent /
% Hagedorn-Manovskii matching) is used to VALIDATE the empirical design: the model
% is calibrated to match ONLY the unemployment QD regression coefficient from the
% data, and we then ask whether it TRULY generates the permanent effects (for all
% three of u, v, theta) that the estimator predicts.
%
% Two rows of Table \ref{valid}:
%   * Data row  = estimator's PREDICTION: empirical QD coef x 1/(1-rho_z*beta) x
%                 log(36/26). Assembled in make_tables.py from the factor-model CSVs
%                 (NOT here).
%   * Model row = the model's TRUE permanent effect of a permanent 10-week benefit
%                 extension, computed HERE.
%
% The TRUE permanent effect is the difference in ergodic-average u/v/theta between
% two solved-and-simulated economies: the baseline EB schedule (26/39/46 weeks at the
% u>0 / 6% / 8% triggers) and the SAME schedule permanently shifted +10 weeks
% (36/49/56). Shifting the whole schedule -- not just the 26-week base -- is what
% weights the recession states where benefits actually bind, and is what reproduces
% the published level. (A single-state z=1 two-point comparative static,
% compute_perm_effect.m below, under-shoots by ~0.8x and is reported only for
% reference.)
%
% Calibration: committed parameters from tab:calib (found by calibrate_model.m, an
% fsolve targeting [coef-0.05317; avgf-0.139; avgt-0.634]). The baseline run here
% re-confirms avgf=0.139 and avgt=0.634; the benefit coefficient 0.0528 is recovered
% by the QD regression on the simulated panel in ModelPanelRegression.do.
%
% Run:  cd ModelCode; matlab -batch RunModel
% Outputs (into output/factor_results/):
%   ModelPanel_Base.txt   simulated baseline panel (17 cols) for ModelPanelRegression.do
%   ModelValidation.csv   Model-row permanent effects + calibration moments + SS ref
% =========================================================================

clear all; close all; format short;

run(fullfile(fileparts(mfilename('fullpath')),'..','matlab','config.m')); SaveDir=[factor_csv filesep];

% --- committed calibration (tab:calib) ---
h   = 0.609460679;
xi  = 0.083442136;
chi = 0.4022;            % matching parameter (NOT the lever for the v/theta fit)
b   = 0.4;
cnum = 1;                % counties per pair in the simulation
Arho = 0;                % no county-specific common-component loading (2D track)

load Sequences_2018_07_30   % shock draws Yvec/Yvec2/Avec/Avec2 used by the simulator

% ----------------------------------------------------------------------
% (1) BASELINE economy: schedule 26/39/46
% ----------------------------------------------------------------------
benefit_offset = 0;
kernel_solve_nested
[~, avgt0, avgf0, avgv0, avgu0] = nested_state_county_simulate( ...
    Yvec,Yvec2,Avec,Avec2,cnum,A,PiA,U,anum,unum,up,eps_base,yp,pp,Pi,Z,znum, ...
    xi,h,chi,b,Arho,yp_state, [SaveDir 'ModelPanel_Base.txt'], 1);
fprintf('BASELINE : avg u=%.5f  theta=%.5f  f=%.5f  v=%.6f\n', avgu0,avgt0,avgf0,avgv0);

% ----------------------------------------------------------------------
% (2) EXTENDED economy: whole schedule permanently +10 weeks -> 36/49/56
% ----------------------------------------------------------------------
clearvars benefit_offset
benefit_offset = 10;
kernel_solve_nested
[~, avgt1, avgf1, avgv1, avgu1] = nested_state_county_simulate( ...
    Yvec,Yvec2,Avec,Avec2,cnum,A,PiA,U,anum,unum,up,eps_base,yp,pp,Pi,Z,znum, ...
    xi,h,chi,b,Arho,yp_state, [SaveDir 'ModelPanel_Ext.txt'], 1);
fprintf('EXTENDED : avg u=%.5f  theta=%.5f  f=%.5f  v=%.6f\n', avgu1,avgt1,avgf1,avgv1);

% ----------------------------------------------------------------------
% (3) Model-row true permanent effects (log differences of ergodic averages)
% ----------------------------------------------------------------------
du = log(avgu1) - log(avgu0);
dt = log(avgt1) - log(avgt0);
dv = log(avgv1) - log(avgv0);
fprintf('MODEL ROW (true perm effect): dlog u=%+.4f  dlog theta=%+.4f  dlog v=%+.4f\n', du,dt,dv);
fprintf('  published: +0.157 / -0.279 / -0.133\n');

% ----------------------------------------------------------------------
% (4) Reference: single-state z=1 two-point SS comparative static (26 vs 36 wks).
%     Reported for documentation only -- it under-shoots (~0.8x) because it does
%     not weight the recession states the way the schedule-shift simulation does.
% ----------------------------------------------------------------------
ss = compute_perm_effect(xi,b,h,chi,1);   % [dlog u, dlog theta, dlog v, ...]
fprintf('SS ref (z=1, 26->36): dlog u=%+.4f  dlog theta=%+.4f  dlog v=%+.4f\n', ss(1),ss(2),ss(3));

% ----------------------------------------------------------------------
% (5) Write CSV consumed by make_tables.py for tab:valid Model row.
%     row layout (one row): du dt dv | avgu0 avgt0 avgf0 | avgu1 avgt1 avgf1 | ss_u ss_t ss_v
% ----------------------------------------------------------------------
out = [du dt dv  avgu0 avgt0 avgf0  avgu1 avgt1 avgf1  ss(1) ss(2) ss(3)];
dlmwrite([SaveDir 'ModelValidation.csv'], out, 'precision', '%.6f');
disp('wrote ModelValidation.csv');
