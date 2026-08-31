% ---------------------------------------------------------------------------
% 1_backoutf_fp.m  ->  jobfindingfp_v12.txt   (monthly county job-finding probability)
%
% Backs out the monthly county job-finding probability F from continuing-claims flows
% (the "forward" duration method). For each of 1268 county claims series
% (CountyClaims/QBLS{i}.txt, 10 named columns) it computes the claims exit rate phi,
% seeds the last 6 months with the CPS L26-Shimer job-finding rates, and runs the
% backward duration recursion. Writes [Fips Year Month F].
%
% NOTE: backoutf_fp_cohort.m also writes jobfindingfp_v12.txt by a DIFFERENT (cohort)
% method -- this "forward" routine is the production one.
%
% Raw input: county continuing-claims QBLS in
%   data/raw/claims/CountyClaims/ (1268 files,
%   built by CLAIMS/Script/construct_claims.do + initialclaims_merge.do from county UI claims).
% ---------------------------------------------------------------------------
clear all; close all
% paths come from the single MATLAB config (edit `root` there once); the
% claims locations below override the QBLS InputBaseDir config sets for the
% factor-model front-ends
run(fullfile(fileparts(mfilename('fullpath')),'..','..','..','matlab','config.m'));
InputBaseDir=fullfile(rawdata,'claims','CountyClaims',filesep);
OutFile     =fullfile(rawdata,'claims','jobfindingfp_v12.txt');

for i=1:1268
    temp = importdata([InputBaseDir 'QBLS' num2str(i) '.txt']);
    for j=1:10
        assignin('base',temp.textdata{1,j},temp.data(:,j));
    end
    len=length(unemp_count);
    phi = (unemp_count(1:len-1)-unemp_count(2:len)+separation(1:len-1).*(labor(1:len-1)-unemp_count(1:len-1)))./unemp_count(1:len-1);
    phi=max(min(phi,0.99),0.01);
    f=zeros(len,1);
    f(end-5:end,1)=[.3587613 .4049303 .3843236 .4100648 .4120205 .3903891]; %CPS L26 shimer
    finalp=zeros(len,1);
    finalp(1:end-1)=finalpm1(2:end)+finalpm2(2:end)+finalp3(1:end-1);
    for t=len-6:-1:1
       f(t)=1-(finalp(t+1)+...
           (finalp(t+2)/(1-f(t+1)))+...
           (finalp(t+3)/((1-f(t+1))*(1-f(t+2))))+...
           (finalp(t+4)/((1-f(t+1))*(1-f(t+2))*(1-f(t+3))))+...
           (finalp(t+5)/((1-f(t+1))*(1-f(t+2))*(1-f(t+3))*(1-f(t+4))))...
           )/(claims(t)-finalpm2(t));
       f(t)=max(min(f(t),1),0);
    end
    if i>1
        Year=[Year;year]; Month=[Month;month]; Fips=[Fips;fipsnumeric]; F=[F;f]; %#ok<*AGROW>
    else
        Year=year; Month=month; Fips=fipsnumeric; F=f;
    end
end
dlmwrite(OutFile,[Fips Year Month F]);
fprintf('wrote %s : %d county-months\n', OutFile, length(F));
