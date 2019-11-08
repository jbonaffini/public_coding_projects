
% Using ode45
%    [TF*	Xa		IXa		XIa		Fibrin		IIa		ES		yS]
c0 = [1		0.17	0.09	.031		18		1.4		2.8		0.1];
c0 = [1		0.17	0.09	.031		18		0		0		1.4];

tspan = [0 850];
[t,c] = ode15s(@Fibrin_Thrombin_ode,tspan,c0);

figure; subplot(221); plot(t,c(:,3)); axis tight;
xlabel('time(sec)'); ylabel ('IXa or XIa');
title('Intrinsic tenase');
subplot(222); plot(t,c(:,2));
xlabel('time(sec)'); ylabel ('Xa');
title('Prothrombinase');

subplot(223); plot(t,c(:,8)); axis tight;
xlabel('time(sec)'); ylabel ('IIa');
title('Thrombin');
subplot(224); plot(t,c(:,8));
xlabel('time(sec)'); ylabel ('IIa');
title('Thrombin');

% figure; plot(t,c(:,8));