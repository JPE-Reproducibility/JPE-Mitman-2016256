clear; format long;
config;   % after clear (clear would wipe the config paths); sets figures dir
load(fullfile(fileparts(mfilename('fullpath')),'kit_mc_baseline.mat'));   % Xb Yb Mb bet
rng('default');
ng=1000; guesses=randn(ng,1); est=zeros(ng,1);
for i=1:ng
  est(i) = mc_fixedr(Xb, Yb, 2, Mb, guesses(i));
end
p5=prctile(est,5); p95=prctile(est,95);
fprintf('==FIG== n=%d  benchmark=%.8f  5th pct=%.8f  95th pct=%.8f  (paper 0.05317857 / 0.05317863)\n', ng, bet, p5, p95);
fprintf('==FIG== min=%.8f max=%.8f range=%.2e\n', min(est), max(est), max(est)-min(est));
f=figure('visible','off');
scatter(guesses, est, 18, 'filled'); hold on;
yline(bet,'r--','LineWidth',1.5);
xlabel('Initial guess \alpha_1','FontSize',13);
ylabel('Estimated coefficient \alpha','FontSize',13);
ylim([bet-0.001 bet+0.001]);
set(gca,'FontSize',12); box on;
print(f, [figures filesep 'initial_guess.pdf'], '-dpdf');   % paper \graphicspath = output/figures
exit
