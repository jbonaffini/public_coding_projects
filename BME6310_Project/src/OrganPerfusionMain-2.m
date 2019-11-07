%OrganPerfusionMain.m

%Organ properties
L = 500*10^-6; %capillary length (m)
r = 4*10^-6; %capillary radius (m)
Vc0 = 3.14*(50*10^-6)^2*L; %initial volume of tissue cylinder (m^3)
Vorgan = 150*10^-6; %initial organ volume (m^3)
N = Vorgan/Vc0; % number of tissue cylinders
Phi0 = 0.4; %initial solids volume fraction of organ
Cfc0 = 20; %initial concentration of fixed charges (mmol/L = mol/m^3)
LpS = 10^-16; %(hydraulic conductivity)*(capillary circumference) (m^3/m/s/Pa)
P1S = 10^-14; %(permeability of solute 1)*(capillary circumference) (m^3/m/s)
P2S = 10^-9; %(permeability of solute 2)*(capillary circumference) (m^3/m/s)
P3S = 10^-13; %(permeability of solute 3)*(capillary circumference) (m^3/m/s)
sigma1 = 0.9; %reflection coefficient for solute 1
sigma2 = 0.3; %reflection coefficient for solute 2
sigma3 = 0.3; %reflection coefficient for solute 3
alpha = 7.5*10^-6; %organ compliance (mL/mL/Pa)

%Constant parameters
R = 8.314; %gas constant, J/mol/K
T = 37+273; %temperature, K
mu = 10^-3; %viscosity of perfusion solution (Pa s)

%place all required constant parameters in a single vector
parameters = [LpS P1S P2S P3S sigma1 sigma2 sigma3 R T Cfc0 Phi0 Vc0 r mu];

%Inlet conditions for differential equation
C10 = 1.3; %concentration of uncharged solute 1 at capillary inlet (mmol/L = mol/m^3)
C20 = 1600; %concentration of uncharged solute 2 at capillary inlet (mmol/L = mol/m^3)
C30 = 45; %concentration of charged solute (salt) at capillary inlet (mmol/L = mol/m^3)
Q0 = (600*10^-6/60)/N; %fluid flow rate at capillary inlet (m^3/s) 
P0 = 20*101325/760; %hydrostatic pressure at capillary inlet (Pa)
ICs = [C10 C20 C30 Q0 P0];

%Initial properties of interstitial space
Pi = 5*101325/760; %gauge pressure in interstitial space
Ci1 = 0.5; %concentration of solute 1 in interstitial space
Ci2 = 0; %concentration of solute 2 in interstitial space
Ci3 = 140; %concentration of solute 3 in interstitial space
Vc = Vc0; %volume of tissue cylinder surrounding capillary

%Vector of times to solve for organ properties
dt=0.5; %time increment (s)
times = 0:dt:3600;
%Define vectors to contain parameter values for each time point
Pis = [Pi zeros(1,length(times(2:end)))]; 
Ci1s = [Ci1 zeros(1,length(times(2:end)))];
Ci2s = [Ci2 zeros(1,length(times(2:end)))];
Ci3s = [Ci3 zeros(1,length(times(2:end)))];
Vcs = [Vc zeros(1,length(times(2:end)))];
dPcs = zeros(1,length(times));

for i = 1:length(times)-1
    Pi = Pis(i);
    Ci1 = Ci1s(i);
    Ci2 = Ci2s(i);
    Ci3 = Ci3s(i);
    Vc = Vcs(i);
    options = [];
    [x,y]=ode45(@CapillaryModel, [0 L], ICs, options, Pi,Ci1,Ci2,Ci3,Vc,parameters);
    %calculate parameter values at i+1
    Vcs(i+1)=Vcs(i)-(y(end,4)-y(1,4))*dt;
    Pis(i+1)=Pis(1)+(1/alpha)*(Vcs(i+1)-Vcs(1))/Vcs(1);
    Ci1s(i+1)=(Ci1s(i)*(Vcs(i)-Phi0*Vcs(1))-(y(end,1)*y(end,4)-y(1,1)*y(1,4))*dt)/(Vcs(i+1)-Phi0*Vcs(1));
    Ci2s(i+1)=(Ci2s(i)*(Vcs(i)-Phi0*Vcs(1))-(y(end,2)*y(end,4)-y(1,2)*y(1,4))*dt)/(Vcs(i+1)-Phi0*Vcs(1));
    Ci3s(i+1)=(Ci3s(i)*(Vcs(i)-Phi0*Vcs(1))-(y(end,3)*y(end,4)-y(1,3)*y(1,4))*dt)/(Vcs(i+1)-Phi0*Vcs(1));
    dPcs(i+1)=y(1,5)-y(end,5);
end


subplot(3,2,1), plot(times,Vcs./Vcs(1)), xlabel('time (s)'), ylabel('Relative Organ Volume')
subplot(3,2,2), plot(times,Pis./101325*760), xlabel('time (s)'), ylabel('Interstitial Pressure (mm Hg)')
subplot(3,2,3), plot(times, Ci1s), xlabel('time (s)'), ylabel('Colloid Concentration (mOsm/L)')
subplot(3,2,4), plot(times, Ci3s), xlabel('time (s)'), ylabel('Salt Concentration (mmol/L)')
subplot(3,2,5), plot(times, Ci2s), xlabel('time (s)'), ylabel('CPA Concentration (mmol/L)')
subplot(3,2,6), plot(times(2:end),dPcs(2:end).*760./101325), xlabel('time (s)'), ylabel('Capillary Pressure Drop (mm Hg)')