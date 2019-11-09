
% c0 = [1		0.17	0.09	.031		18		1.4		2.8		0.1];

% Starting values
%    [TF*			Xa			IXa			XIa		
%		Fibrin		ES			yS			IIa]
c0 = [1*10^-6		0.17*10^-6	0.09*10^-6	.031*10^-6 ...
		0*10^-6		0*10^-6		0*10^-6		1.4*10^-6];

tspan = 0:1:850;

% Parameters - Total Pathway
p.k_i_TF = log(2) / 180;
p.k_i = log(2) / 60;
p.k_elute = log(2) / 2;
p.n = [1 1 1 0.18 0.05 0.36 1];
a = [0.48 0.32 5.53 24.7 58.8 4.98*10^-5 0.065];
p.a = [0.48 0.32 5.53 24.7 58.8 4.98*10^-5 0.065];
p.E_O_total = 1.6; p.Ek_f = 280; p.Ek_r = 280;
p.y_O_total = 0.3; p.yk_f = 10; p.yk_r = 10;

% Parameters - Extrinsic & Intrisic (XIa=0, a(6)=a(7)=0)
pEI = p;
pEI.a = [0.48 0.32 5.53 24.7 58.8 0 0];

% Parameters - Extrinsic Only (XIa=IXa=0, a(2)=0)
pE = p;
pE.a = [0.48 0 5.53 24.7 58.8 4.98*10^-5 0.065];

% ODE15s it
[t,c] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],p);
[tEI,cEI] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],pEI);
[tE,cE] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],pE);

% Plot it

figure; subplot(221); plot(t,c(:,3),'b-',...
	t,c(:,3)-cEI(:,3),'r-',...
	t,cEI(:,3),'y-',...
	t,c(:,4),'m--','LineWidth', 2); 
xlabel('time(sec)'); ylabel ('IXa or XIa');
title('Intrinsic tenase'); axis tight;
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)', 'XIa');
subplot(222); plot(t,c(:,2),'b-',...
	t,c(:,2)-cEI(:,2),t,cEI(:,2),'y-',t,cE(:,2),'m--','LineWidth', 2);
xlabel('time(sec)'); ylabel ('Xa');
title('Prothrombinase'); axis tight;
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)',...
	'Extrinsic Only (XIa,IXa=0),(x 100)');

subplot(223); plot(t,c(:,8));
xlabel('time(sec)'); ylabel ('IIa');
title('Thrombin');  axis tight;
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)',...
	'Extrinsic Only (XIa,IXa=0),(x 100)');
subplot(224); plot(t,c(:,8));
xlabel('time(sec)'); ylabel ('IIa');
title('Thrombin'); axis tight;
legend('Total', 'Weak Bonding', ...
	'Strong Bonding', 'Free IIa (x 10)');

% figure; plot(t,c(:,8));

% figure; plot(t,c(:,6),t,c(:,7), t,c(:,8)*10);
% legend('Weak Bonding', 'Strong Bonding', 'IIa');