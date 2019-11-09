function [ddt] = Fibrin_Thrombin_ode (t,c,p)

	% constants
	
	k_i_TF = p.k_i_TF; k_i = p.k_i; k_elute = p.k_elute;
	n = p.n; a = p.a;
	E_O_total = p.E_O_total * c(5); 
	Ek_f = p.Ek_f; Ek_r = p.Ek_r;
	y_O_total = p.y_O_total * c(5);
	yk_f = p.yk_f; yk_r = p.yk_r;

	% ODEs
	
	ddt(1) = -k_i_TF * c(1); % dTF/dt
	ddt(2) = a(1) * c(1) + a(3) * c(3) - k_i * c(2); % dXa/dt
	ddt(3) = a(2) * c(1) + a(7) * c(4) - k_i * c(3); % dIXa/dt
% 	ddt(4) = n(6) * a(6) * c(6) - k_elute * c(4) - k_i * c(4); % dXIa/dt
% 	ddt(5) = n(5) * a(5) * c(6); % dFibrin/dt
% 	ddt(6) = n(4) * a(4) * c(2) - (ddt(7) + ddt(8)) - k_elute * c(6) - k_i * c(6); % dIIa/ dt
% 	ddt(7) = Ek_f * c(6) * (E_O_total - c(7)) - Ek_r * c(7); % dES/dt
% 	ddt(8) = yk_f * c(6) * (y_O_total - c(8)) - yk_r * c(8); % dyS/dt
	
	ddt(4) = n(6) * a(6) * c(8) - k_elute * c(4) - k_i * c(4); % dXIa/dt
	ddt(5) = n(5) * a(5) * c(8); % dFibrin/dt
	ddt(6) = Ek_f * c(8) * (E_O_total - c(6)) - Ek_r * c(6); % dES/dt
	ddt(7) = yk_f * c(8) * (y_O_total - c(7)) - yk_r * c(7); % dyS/dt
	ddt(8) = n(4) * a(4) * c(2) - (ddt(6) + ddt(7)) - k_elute * c(8) - k_i * c(8); % dIIa/ dt

	ddt = ddt';
end

