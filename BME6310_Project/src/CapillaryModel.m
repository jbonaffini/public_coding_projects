%THIS IS THE MODEL USED FOR HILL JOHNSON'S THESIS PROJECT%
%MODEL DOES NOT ACCOUNT FOR FIXED CHARGES AND/OR DONNAN EQUILIBRIUM%
%SEE 'DonnanCapillaryModel' TO MODEL FIXED CHARGES%

function dy = CapillaryModel(x,y,Pi,Ci1,Ci2,Ci3,Vc,parameters)
dy = zeros(5,1);
%y(1) = C1 = concentration of uncharged solute 1
%y(2) = C2 = concentration of uncharged solute 2
%y(3) = C3 = concentration of charged solute (salt)
%y(4) = Q = volumetric flow rate through capillary
%y(5) = P = pressure in capillary

%Constant parameters:
  LpS = parameters(1);
  P1S = parameters(2);
  P2S = parameters(3);
  P3S = parameters(4);
  sigma1 = parameters(5);
  sigma2 = parameters(6);
  sigma3 = parameters(7);
  R = parameters(8);
  T = parameters(9);
  Cfc0 = parameters(10);    %FIXED CHARGES NOT MODELED DESPITE THIS PARAMETER%
  Phi0 = parameters(11);
  Vc0 = parameters(12);
  r = parameters(13);
  mu = parameters(14);


%Calculate the volume flow from the capillary to the interstitium
Jv = LpS*((y(5)-Pi)-R*T*(sigma1*(y(1)-Ci1)+sigma2*(y(2)-Ci2)+sigma3*(y(3)-Ci3)));

%Calculate "average" solute concentrations for use with flux model.  Note
%that for high volume flow from the capillary to the interstitium, the
%exponential term becomes too large for Matlab to handle and it treats it
%as infinity.  In this case, the first term in the equation reduces to the
%solute concentration in the capillary. The if statements below deal with
%this issue
if Jv/P1S < 100
    C1avg = (Ci1-y(1)*exp(Jv/P1S))/(1-exp(Jv/P1S))-(P1S/Jv)*(y(1)-Ci1);
else
    C1avg = y(1)-(P1S/Jv)*(y(1)-Ci1);
end

if Jv/P2S < 100
    C2avg = (Ci2-y(2)*exp(Jv/P2S))/(1-exp(Jv/P2S))-(P2S/Jv)*(y(2)-Ci2);
else
    C2avg = y(2)-(P2S/Jv)*(y(2)-Ci2);
end
if Jv/P3S < 100
    C3avg = (Ci3-y(3)*exp(Jv/P3S))/(1-exp(Jv/P3S))-(P3S/Jv)*(y(3)-Ci3);
else
    C3avg = y(3)-(P3S/Jv)*(y(3)-Ci3);
end

%Calculate the solute flows from the capillary to the interstitium
J1 = P1S*(y(1)-Ci1)+Jv*(1-sigma1)*C1avg;
J2 = P2S*(y(2)-Ci2)+Jv*(1-sigma2)*C2avg;
J3 = P3S*(y(3)-Ci3)+Jv*(1-sigma3)*C3avg;

%Solve differential equations to be plotted in the main perfusion script
dy(1) = (1/y(4))*(-J1+y(1)*Jv);
dy(2) = (1/y(4))*(-J2+y(2)*Jv);
dy(3) = (1/y(4))*(-J3+y(3)*Jv);
dy(4) = -Jv;
dy(5) = -8*mu*y(4)/(3.14*r^4);