function [ds] = stateFunc(t,state,vw)


g=9.80665;              %[m/s] % Gravity Constant
rhoAtm=.961;            %[kg/m3] % Ambient Air Density
Dbot= 0.021;    %[m] % Diameter of Bottle
mBot=0.16;       %[kg] % Mass of Empty Bottle
CD= 0.3;            % Drag Coefficient

% Calculated Constants
Abot=pi*(Dbot/2)^2;   % Area of Bottle

vx=state(1);   
vy=state(2);   
vz=state(3);    
x0=state(4);    
y0=state(5);     
z0=state(6);     



    vRel = [vx +vw(1), vy + vw(2), vz + vw(3)];        % add wind components
    velo = norm(vRel);                              % Vector magnitude
    Fdrag = (1/2)*rhoAtm*(velo^2)*CD*Abot;    % Drag Force

    temp = sqrt(vRel(1)^2+vRel(2)^2);   % hypotenuse of flight path xy proj
    theta = atan(vRel(3)/ temp);        % The angle value at any point
    beta = atan(vRel(2)/ temp);         % Lateral angle value at any point

    dragx = Fdrag*cos(theta)*cos(beta);          % x-component of drag
    dragz = Fdrag*sin(theta);                    % z-component of drag
    dragy = Fdrag*cos(theta)*sin(beta);          % y-component of drag

    mSystem = mBot;      % Mass of the system for use in F=ma
    Fgrav = mSystem*g;   % Force from Gravity

    dvx = -(dragx / mSystem);              % Acceleration in x --> integrates to vel x
    dvz = (-dragz-Fgrav) / mSystem;   % Same as above, in z direction
    dvy = dragy / mSystem;             % acceleration in y direction

    dx = vx; % velocity x --> integrates to distance x
    dy = vy; % same as above, in y direction
    dz = vz; % same as above, in z direction

  

    ds=[dvx;dvy;dvz;dx;dy;dz]; % output call for ode45


end