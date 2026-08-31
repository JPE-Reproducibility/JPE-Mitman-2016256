do "config.do"
global direc = "${root_dropbox}/"
use ${rawdata}/QCEWAllYears_2014Q4, clear

collapse qcew* state_qcew*, by(fipsnumeric year quarter)

save ${rawdata}/QCEWAllYears_Quarterly_2014Q4, replace
