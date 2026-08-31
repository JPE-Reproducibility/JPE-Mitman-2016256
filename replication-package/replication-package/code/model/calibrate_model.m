function resid=calibrate_model(X)
% =========================================================================
% calibrate_model.m  ->  documents how tab:calib (h, xi, chi) was found.
%
% fsolve residual for the three calibration targets:
%   resid = [ coef - 0.05317 ;  avgf - 0.139 ;  avgt - 0.634 ]
% i.e. the QD unemployment regression coefficient, mean job-finding, and mean
% tightness from a solve+simulate of the 2D economy (cnum=1, one pair as a
% long time series). The committed solution is X = [h xi chi] = [0.6095 0.0834 0.4022]
% (reported in tab:calib). Re-running the fsolve is expensive and NOT part of routine
% replication -- the parameters are given; RunModel.m re-confirms avgf/avgt and
% code/analysis/ModelPanelRegression.do re-confirms the coefficient (0.0528).
%
% NOTE: the `coef` returned by nested_state_county_simulate is disabled in the
% committed simulator (its inline regress is commented out, coef1=0), so to actually
% evaluate this residual the coefficient moment is read from the QD regression on the
% written panel. This script documents the calibration design.
% =========================================================================

h=X(1);
xi=X(2);
chi=X(3);
cnum=1;
Arho=0;
kernel_solve_nested
load Sequences_2018_07_30
outname='Scratch.txt';
[coef,avgt,avgf]=nested_state_county_simulate(Yvec,Yvec2,Avec,Avec2,cnum,A,PiA,U,anum,unum,up,eps_base,yp,pp,Pi,Z,znum,xi,h,chi,b,Arho,yp_state,outname,1);
resid=[(coef-0.05317);avgf-0.139;avgt-0.634];
