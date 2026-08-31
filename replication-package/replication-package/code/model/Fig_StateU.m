% =========================================================================
% Fig_StateU.m  ->  StateUCrop.pdf  (paper fig:endogeneity_test_unemp)
%
% "County and State Unemployment: Model." Illustrates how, in the simulated
% economy, a state-level benefit extension (driven by the STATE unemployment
% rate crossing the EB triggers) leaves the small border county's own labor
% market essentially unaffected -- the visual counterpart of the endogeneity
% test in sec:endogeneity_test.
%
% The original 2013 producer was lost; this reproduces the figure in spirit
% from the kit's baseline simulated panel (code/model/RunModel.m ->
% ModelPanel_Base.txt; Arho=0, i.e. NO correlation between state and county
% productivity -- the benchmark simulation). Panel columns (fixed order):
%   3 time | 7 Eout=benefit weeks | 8 Uout=county u | 11 AUout=state u
% Eout is keyed to the county's STATE unemployment (AUout): 26 wks normally,
% 39 wks once state u>6% -- so the green benefit line steps up with the blue
% state-u line. (Transition quarters can show an intermediate value because
% Eout is the within-quarter average of weekly 1/eps.)
%
% We select a representative ~30-quarter episode: a clean 26 -> 39 -> 26
% benefit cycle (a 5-quarter 39-week spell bracketed by 26-week runs), in
% which state u traces a hump to ~7% while the county's own u stays lower and
% smoother. Two y-axes: LEFT = unemployment rate (state blue, county red),
% RIGHT = weeks of benefits (green dotted, circle markers).
%
% Run:  cd ModelCode; matlab -batch Fig_StateU      (after RunModel.m)
% Output: output/figures/StateUCrop.pdf
% =========================================================================

clear; close all;
run(fullfile(fileparts(mfilename('fullpath')),'..','matlab','config.m'));
ResultsDir=[factor_csv filesep];      % ModelPanel_Base.txt (written by RunModel.m)
SaveDir=[figures filesep];            % StateUCrop.pdf (paper \graphicspath = output/figures)

M  = dlmread([ResultsDir 'ModelPanel_Base.txt']);
c1 = M(M(:,2)==1, :);                 % county 1 of the pair
t  = c1(:,3); e = c1(:,7); cu = c1(:,8); su = c1(:,11);

% --- representative episode (see header). The window is fixed because the
%     baseline simulation is deterministic (fixed Sequences_2018_07_30 shocks). ---
W0 = 2994; W1 = 3024;
idx = t >= W0 & t <= W1;
tt = t(idx); ee = e(idx); ccu = cu(idx); ssu = su(idx);

blue  = [0 0 0.75];
red   = [0.85 0 0];
green = [0 0.55 0];

fig = figure('Position',[100 100 780 480], 'Color','w');

yyaxis left
plot(tt, ssu, '-',  'Color',blue, 'LineWidth',2.5); hold on
plot(tt, ccu, '-',  'Color',red,  'LineWidth',2.5);
ylabel('Unemployment Rate');
ylim([0.03 0.095]);

yyaxis right
plot(tt, ee, ':o', 'Color',green, 'LineWidth',1.5, ...
     'MarkerFaceColor',green, 'MarkerEdgeColor',green, 'MarkerSize',6);
ylabel('Weeks of Benefits');
ylim([26 39.5]);

ax = gca;
ax.Color = 'white';              % white plot background (avoid exportgraphics black fill)
ax.YAxis(1).Color = blue;
ax.YAxis(2).Color = green;
ax.FontSize = 13;
xlabel('Time'); xlim([W0 W1]);
box on;

% inline labels (no legend), positioned in data coordinates
yyaxis left
text(3014, 0.073, 'State Unemployment',  'Color',blue, 'FontSize',13);
text(3012, 0.041, 'County Unemployment', 'Color',red,  'FontSize',13);
yyaxis right
text(W0+0.5, 36.5, {'Weeks of','Benefits'}, 'Color',green, 'FontSize',13);

set(fig,'PaperPositionMode','auto');
exportgraphics(fig, [SaveDir 'StateUCrop.pdf'], 'ContentType','vector');
fprintf('wrote StateUCrop.pdf  (episode t=%d-%d, 39-week spell qtrs=%d)\n', ...
        W0, W1, sum(ee>=37 & ee<=41));
