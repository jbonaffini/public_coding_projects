
% c0 = [1		0.17	0.09	.031		18		1.4		2.8		0.1];

% Starting values
%    [TF*			Xa			IXa			XIa		
%		Fibrin		ES			yS			IIa]
c0 = [1*10^-6		0.17*10^-6	0.09*10^-6	.031*10^-6 ...
		18*10^-6		0*10^-6		0.09*10^-6		1.4*10^-6];

tspan = 0:1:850;

% Parameters - Total Pathway
p.k_i_TF = log(2) / 180;
p.k_i = log(2) / 60;
p.k_elute = log(2) / 2;
p.n = [1 1 1 0.18 0.05 0.36 1];
% p.a. changed to represent severe hemophilia . a(2)=a(3)=0 
% no intrinsic tenase. All prothrobinase is the result of 
%extrinsic tenase
    p.a = [0.48 0.32 5.53 24.7 58.8 4.98*10^-5 0.065];
    
    
p.E_O_total = 1.6; p.Ek_f = 280; p.Ek_r = 280;
p.y_O_total = 0.3; p.yk_f = 10; p.yk_r = 10;

% Parameters - mild hemophilia (40% a(2) and a(3) relative to normal)
pmild = p;
    pmild.a = [0.48 0.1280 2.212 24.7 58.8 0 0];

% Parameters - moderate hemophilia (5% a(2) and a(3) relative to normal)
pE = p;
    pE.a = [0.48 0.0160 0.2765 24.7 58.8 4.98*10^-5 0.065];
    
% Parameters - severe hemophilia (1% a(2) and a(3) relative to normal)
pS = p;
    pS.a = [0.48 0.0032 0.0553 24.7 58.8 4.98*10^-5 0.065];

% Parameters - most severre hemophilia (no a(2) and a(3) representing no intrinsic pathway)
pZ = p;
    pZ.a = [0.48 0 0. 24.7 58.8 4.98*10^-5 0.065];

    % ODE15s it
[t,c] = ode15s(@fibrin_thrombin_ode_hemophilia,tspan,c0,[],p);
[tEI,cEI] = ode15s(@fibrin_thrombin_ode_hemophilia,tspan,c0,[],pmild);
[tE,cE] = ode15s(@fibrin_thrombin_ode_hemophilia,tspan,c0,[],pE);
[tS,cS] = ode15s(@fibrin_thrombin_ode_hemophilia,tspan,c0,[],pS);
[tZ,cZ] = ode15s(@fibrin_thrombin_ode_hemophilia,tspan,c0,[],pZ);


% Plot it
%figure('Renderer', 'painters', 'Position', [10 10 1200 900])

% % Intrinsic Tenase
% subplot(221); plot(t,(c(:,3)+c(:,4))*10^6,'b-',...
% 	tEI,(cEI(:,3)+cEI(:,4))*10^6,'r-',...
% 	tE,(cE(:,3)+cE(:,4))*10^6,'y-',...
% 	tS,cS(:,3)+cS(:,4)*10^6,'m--','LineWidth', 2); 
% xlabel('time(sec)'); ylabel ('IXa or XIa [pM]');
% title('Intrinsic tenase'); axis([0 1000 0 30]);
% legend('Total Pathway', 'Feedback (a-c)',...
% 	'Extrinsic and Intrinsic (XIa=0)', 'XIa',...
% 	'FontSize',8,'Location','best');
% legend('boxoff')
% 
% % Prothrombinase
% subplot(222); plot(t,c(:,2)*10^3,'b-',...
% 	t,(c(:,2)-cEI(:,2))*10^3,'r-',...
% 	t,cEI(:,2)*10^3,'y-',...
% 	t,cE(:,2)*100*10^3,'m--','LineWidth', 2);
% xlabel('time(sec)'); ylabel ('Xa [nM]');
% title('Prothrombinase'); axis([0 1000 0 15]);
% legend('Total Pathway', 'Feedback (a-c)',...
% 	'Extrinsic and Intrinsic (XIa=0)',...
% 	'Extrinsic Only (XIa,IXa=0),(x 100)',...
% 	'FontSize',8,'Location','best');
% legend('boxoff')

% Thrombin
%plot on log scale (y) 
figure; plot(t,c(:,6)+c(:,7),'b-',...
	tEI,cEI(:,6)+cEI(:,7),'r-',...
	tE,cE(:,6)+cE(:,7),'y-',...
	tS,(cS(:,6)+cS(:,7)),'m--','LineWidth', 2); 
xlabel('time(sec)'); ylabel ('Concentration of Bound Thrombin [\muM]');
title('Thrombin'); axis([0 850 0 20]);
legend('Normal', 'Mild Hemophilia, 40% FVIIIa',...
	'Moderate Hemophilia, 5% FVIIIa',...
	'Severe Hemophilia, 1% FVIIIa',...
	'FontSize',8,'Location','best');
legend('boxoff')

