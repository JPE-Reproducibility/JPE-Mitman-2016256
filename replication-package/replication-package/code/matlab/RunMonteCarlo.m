clear; format short;
config;
% the MC baseline panel ships next to this script
load(fullfile(fileparts(mfilename('fullpath')),'kit_mc_baseline.mat'));  % Xb Yb Mb lam Fb bet borderid
rng('default');
nmc=2000; r=2; sdoverall=sqrt(0.008641);
% cells: {panel, rho^t, rho^s}; rho^t se=0.02 (+/-3se=0.14/0.02), rho^s se=0.005 (0.575/0.545)
cells = {'A',0.08,0.56; 'B',0.14,0.56; 'B',0.02,0.56; ...
         'C',0.08,0.575; 'C',0.08,0.545; ...
         'D',0.14,0.575; 'D',0.02,0.575; 'D',0.14,0.545; 'D',0.02,0.545};
nc=size(cells,1); res=zeros(nc,4);   % [rho^t rho^s mean median]
fid=fopen([SaveDir 'SenseResultsMonteCarlo.csv'],'w');
fprintf(fid,'panel,rho_t,rho_s,true,mean,median,delta\n');
for c=1:nc
  rt=cells{c,2}; rs=cells{c,3};
  p.rhoeps=rt; p.rhoceps=rt;
  p.sdeps  = sqrt(1-rs)*sdoverall*sqrt(1-rt^2);
  p.sdceps = sqrt(rs)  *sdoverall*sqrt(1-rt^2);
  est=zeros(nmc,1);
  for irun=1:nmc
    Ysim = mc_gendata(bet, lam, Fb, Xb, borderid, p);
    est(irun) = mc_fixedr(Xb, Ysim, r);
  end
  mn=mean(est); md=median(est);
  fprintf('Panel %s  rho^t=%.3f rho^s=%.3f  true=%.4f  mean=%.4f  median=%.4f  delta=%+.4f\n',...
    cells{c,1}, rt, rs, bet, mn, md, mn-bet);
  fprintf(fid,'%s,%.3f,%.3f,%.4f,%.4f,%.4f,%.4f\n', cells{c,1}, rt, rs, bet, mn, md, mn-bet);
end
fclose(fid);
fprintf('=== MONTE CARLO DONE ===\n');
exit
