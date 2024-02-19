function p =cal_fcator(v)
factors=xlsread('CAL_Factor.xlsx');
p=v.*factors(2,:)*10^-3+factors(3,:);



