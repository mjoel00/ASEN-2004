function [deltaV] = getdeltaV(Isp)
clear
clc
close all

g0 = 9.81; %m/s^2
m0 = 1.129; %kg
mf = 0.128; %kg
deltaV = Isp*g0*log(m0/mf); 
end
