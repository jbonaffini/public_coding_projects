
% c0 = [1		0.17	0.09	.031		18		1.4		2.8		0.1] um

% Starting values
%    [TF*			Xa			IXa			XIa		
%		Fibrin			ES			yS			IIa]
c0 = [1*10^-6		0.17*10^-6	0.09*10^-6	.031*10^-6 ...
    18*10^-6		0*10^-6		0.09*10^-6		1.4*10^-6];

tspan = 0:1:850;

% Parameters - Total Pathway
p.k_i_TF = log(2) / 180;
p.k_i = log(2) / 60;
p.k_elute = log(2) / 2;
p.n = [1 1 1 0.18 0.05 0.36 1];
p.a = [0.48 0.32 5.53 24.7 58.8 4.98*10^-5 0.065];
p.E_O_total = 1.6; p.Ek_f = 100; p.Ek_r = 280;
p.y_O_total = 0.3; p.yk_f = 100; p.yk_r = 15;

% Parameters - Extrinsic & Intrisic (XIa=0, a(6)=a(7)=0)
pEI = p;
pEI.a = [0.48 0.32 5.53 24.7 58.8 0 0];

% Parameters - Extrinsic Only (XIa=IXa=0, a(2)=a(3)=0)
pE = p;
pE.a = [0.48 0 0 24.7 58.8 4.98*10^-5 0.065];

% ODE15s it
[t,c] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],p);
[tEI,cEI] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],pEI);
[tE,cE] = ode15s(@Fibrin_Thrombin_ode,tspan,c0,[],pE);

% Plot it
figure('Renderer', 'painters', 'Position', [10 10 1996/2 1673/2])

% Intrinsic Tenase
subplot(221); plot(t,(c(:,3)+c(:,4))*10^6,'-',...
	t,(c(:,3)+c(:,4)-cEI(:,3)-cEI(:,4))*10^6,'-',...
	t,(cEI(:,3)+cEI(:,4))*10^6,'-',...
	t,c(:,4)*10^6,'--','LineWidth', 2); 
xticks([0:200:1000])
yticks([0:5:30])
ylabel ('IXa or XIa [pM]');
title('Intrinsic tenase'); axis([0 1000 0 30]);
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)', 'XIa',...
	'FontSize',8,'Location','best');
legend('boxoff')

% Prothrombinase
subplot(222); plot(t,c(:,2)*10^3,'-',...
	t,(c(:,2)-cEI(:,2))*10^3,'-',...
	t,cEI(:,2)*10^3,'-',...
	t,cE(:,2)*100*10^3,'-','LineWidth', 2);
xticks([0:200:1000])
yticks([0:5:15])
ylabel ('Xa [nM]');
title('Prothrombinase'); axis([0 1000 0 15]);
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)',...
	'Extrinsic Only (XIa,IXa=0),(x 100)',...
	'FontSize',8,'Location','best');
legend('boxoff')

% Thrombin
subplot(223); plot(t,c(:,6)+c(:,7),'-',...
	t,c(:,6)+c(:,7)-cEI(:,6)+cEI(:,7),'-',...
	t,cEI(:,6)+cEI(:,7),'-',...
	t,(cE(:,6)+cE(:,7))*1000,'-','LineWidth', 2); 
xticks([0:200:1000])
yticks([0:5:20])
xlabel('Time [sec]'); ylabel ('IIa [\muM]');
title('Thrombin'); axis([0 1000 0 20]);
legend('Total Pathway', 'Feedback (a-c)',...
	'Extrinsic and Intrinsic (XIa=0)',...
	'Extrinsic Only (XIa,IXa=0),(x 1000)',...
	'FontSize',8,'Location','best');
legend('boxoff')

subplot(224); plot(t,c(:,6)+c(:,7),'-',...
	t,c(:,7),'-',...
	t,c(:,6),'-',...
	t,c(:,8)*10,'-','LineWidth', 2)
xticks([0:200:1000])
yticks([0:5:20])
xlabel('Time [sec]'); ylabel ('IIa [\muM]');
title('Thrombin'); axis([0 1000 0 20]);
legend('Total', 'High affinity-bound', ...
	'Weak-bound', 'Free IIa (x 10)',...
	'FontSize',8,'Location','best');
legend('boxoff')

% figure; plot(t,c(:,8));

% figure; plot(t,c(:,6),t,c(:,7), t,c(:,8)*10);
% legend('Weak Bonding', 'Strong Bonding', 'IIa');

%%
mse_spline (tspan, c(:,3));
function [] = mse_spline  (origx, origy)
	
	test = 50:50:400;
	mse = zeros(1,length(test));
	
	for i = 1 : length(mse)
		mse(i) = ds_spline (origx, origy, test(i));
	end
	
	figure;
	plot(test,mse)
end


function [mse] = ds_spline (origx, origy, ds)
	dsx = downsample(origx,ds);
	dsy = downsample(origy,ds);
	
	pts = round(length(origx) / ds);
	idx = round(linspace(1,length(origx), pts));
	dsx=[]; dsy=[];
	for i = 1 : length(idx)
		dsx = [dsx origx(idx(i))];
		dsy = [dsy origy(idx(i))];
	end
	
	pp = spline(dsx, dsy, origx);
	
	mse = mean( ((pp - origy')./pp).^ 2);
	
	figure;
	plot(origx,origy,'-',...
	dsx,dsy,'-',...
	origx,pp,'k-',...
	'LineWidth', 2); 
	xlabel('x'); ylabel ('y');
	title('');
	legend('Original', 'Downsampled',...
	['Spline Interp: ',num2str(ds)],...
		'FontSize',8,'Location','best');
	legend('boxoff')
end