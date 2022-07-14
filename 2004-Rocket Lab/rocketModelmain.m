clear
clc
close all

% define variables
g = 9.80665;                % gravitational constant
mProp = 1;                  % [kg] [1 L = 1000g = 1kg]
mBot=0.16;           %[kg] % Mass of Empty Bottle
Patm=83000;                 %[Pa] % Atmospheric Pressure
Pgage=2757590;               %[Pa] % Intial Gauge Pressure of air in bottle

vBot=.002;             %[m^3] % Empty bottle Volume
vWat=.001;              %[m^3] % Initial Volume of Water
vAir=vBot-vWat;  % Volume of air in Bottle Initial

R=287;          % Universal Gas Constant Air
Tair=290.15;  

mAir=((Pgage+Patm)*vAir)/(R*Tair);    % Mass of Air Initital
mAirFinal=((Patm)*vAir)/(R*Tair);

Isp = 2;
g0 = 9.81; %m/s^2
m0 = 0.76; %kg
mf = 0.16; %kg
deltaV = Isp*g0*log(m0/mf);
vwx = 2.52;
vwy = 2.52;
vwz = 0;
alpha = 45; %deg
x0 = 0;
y0 = 0;
z0 = 0.5;

vw = [vwx; vwy; vwz];
vx = deltaV * cosd(alpha);
vy = 0;
vz = deltaV * sind(alpha);
vrel = [vx; vy; vz];
h = vrel/deltaV;

state = [vx; vy; vz; x0; y0; z0];
tspan = 0:0.00001:10 ;

[t, ds] = ode45(@(t,ds) stateFunc(t,ds,vw), tspan, state);

finder = find(ds(:,6) < 0) ;
ds(finder,:) = [];

plot3(ds(:,4),ds(:,5),ds(:,6));
xlabel('Downrange [m]')
ylabel('Crossrange [m]')
zlabel('Height [m]')
xlim([0 100]);
ylim([0 0.5]);
zlim([0 30]);
disp(max(ds(:,6)))

% Error Ellipses
x = ds(:,4);
y = ds(:,5);
figure; plot(x,y,'k.','markersize',4)
axis equal; 
title('Error Ellipses'); 
xlabel('Down Wind');
ylabel('Cross Wind'); hold on;

P = cov(x,y);
mean_x = mean(x);
mean_y = mean(y);

n=100; 
p=0:pi/n:2*pi; 
[eigvec,eigval] = eig(P); 
xy = [cos(p'),sin(p')] * sqrt(eigval) * eigvec'; 
x_vect = xy(:,1);
y_vect = xy(:,2);

plot(1*x_vect+mean_x, 1*y_vect+mean_y, 'b')
plot(2*x_vect+mean_x, 2*y_vect+mean_y, 'g')
plot(3*x_vect+mean_x, 3*y_vect+mean_y, 'r')

xlim([0 100]);
ylim([-40 40]);