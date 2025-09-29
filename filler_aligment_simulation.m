%% Magnetic Nanorod Dynamics & EMT Simulation
% Author: GEUNUNG YOO
% Date: 2025-09-29
%
% --- Description ---
% This script simulates the alignment dynamics of magnetic nanorods in a 
% viscous fluid under an external magnetic field using the Langevin equation.
% It then predicts the change in the composite's effective permittivity 
% using Effective Medium Theory (EMT).
% The primary output includes two plots showing the alignment dynamics and
% the predicted capacitance change.

%% --- Initial Setup ---
clear; clc; close all;

DEBUG = true; % Set to true to see debug messages, false to hide them.

output_filename = 'simulation_results.xlsx';
if exist(output_filename, 'file'), delete(output_filename); end


%% --- USER INPUT PARAMETERS ---
% All experimental values and simulation conditions should be set here.

% --- Plotting Parameters ---
params.n_plot_fillers = 5;    % Number of fillers to show in the dynamics plot.

% --- Material Properties ---
params.mol_Fe3O4 = 10;        % mol% of Fe3O4 on BTO fillers. 
params.sigma_s   = 4;         % Saturation magnetization of the filler (emu/g).

% --- Filler Geometry ---
params.L_filler  = 10;        % Length of the nanorod filler (micrometers).
params.d_filler  = 200;       % Diameter of the nanorod filler (nanometers).

% --- Composite Recipe (by weight percent) ---
params.wt_IL      = 20;       % wt% of Ionic Liquid relative to PDMS.
params.wt_filler  = 10;       % wt% of Fillers relative to the matrix (PDMS + IL).

% --- Simulation Conditions ---
params.B         = 0.02;      % Magnetic field strength (Tesla).
params.B_dir_deg = 0;         % Magnetic field direction (degrees).
params.eta       = 0.032;     % Viscosity of the Ionic Liquid (Pa·s).
params.T         = 298;       % Temperature (Kelvin).
params.t_final   = 0.5;       % Total simulation time (seconds).
params.dt        = 1e-4;      % Time step (seconds).
params.n_fillers = 500;       % Number of fillers to simulate.

% --- EMT Parameters (Relative Permittivity) ---
params.eps_matrix = 5;        % Effective permittivity of the matrix (PDMS + IL).
params.eps_filler = 3000;     % Permittivity of the BTO filler (long axis).

% --- Physical Constants ---
constants.MW_Fe3O4 = 231.53;  % g/mol
constants.MW_BTO   = 233.19;  % g/mol
constants.rho_Fe3O4= 5.2;     % g/cm^3
constants.rho_BTO  = 6.0;     % g/cm^3
constants.rho_PDMS = 1.0;     % g/cm^3
constants.rho_IL   = 1.45;    % g/cm^3
constants.kB       = 1.38e-23;% Boltzmann constant (J/K)


%% 1. Calculate Filler & Composite Properties
disp('Step 1: Calculating material properties...');
x_Fe3O4 = params.mol_Fe3O4 / 100;
w_Fe3O4 = (x_Fe3O4 * constants.MW_Fe3O4) / (x_Fe3O4 * constants.MW_Fe3O4 + (1-x_Fe3O4) * constants.MW_BTO);
filler.rho = ((w_Fe3O4 / constants.rho_Fe3O4) + ((1-w_Fe3O4) / constants.rho_BTO))^-1;
frac_IL = params.wt_IL / 100;
w_IL_matrix = frac_IL / (1 + frac_IL); w_PDMS_matrix = 1 - w_IL_matrix;
frac_F = params.wt_filler / 100;
w_total_matrix = 1 / (1 + frac_F);
w_F_total = frac_F * w_total_matrix;
w_PDMS_total = w_PDMS_matrix * w_total_matrix;
w_IL_total = w_IL_matrix * w_total_matrix;
vol_F = w_F_total / filler.rho;
vol_PDMS = w_PDMS_total / constants.rho_PDMS;
vol_IL = w_IL_total / constants.rho_IL;
composite.phi_f = vol_F / (vol_F + vol_PDMS + vol_IL);
filler.L_cm = params.L_filler * 1e-4;
filler.d_cm = params.d_filler * 1e-7;
filler.vol_cm3 = pi * (filler.d_cm / 2)^2 * filler.L_cm;
filler.mass_g = filler.rho * filler.vol_cm3;
m_cgs = params.sigma_s * filler.mass_g;
filler.m_SI = m_cgs * 1e-3;

%% 2. Setup Langevin Dynamics Simulation
disp('Step 2: Setting up Langevin dynamics simulation...');
filler.L_m = filler.L_cm * 1e-2;
filler.d_m = filler.d_cm * 1e-2;
p = filler.L_m / filler.d_m;
if DEBUG, fprintf('\n[DEBUG] Calculated Aspect Ratio p = %.4f (Should be > 1)\n', p); end
if p < 1, p = 1/p; end
gamma_r = (pi * params.eta * filler.L_m^3) / (3 * (log(p) - 0.7));
sim.N_steps = round(params.t_final / params.dt);
sim.time = linspace(0, params.t_final, sim.N_steps);
sim.B_dir_rad = deg2rad(params.B_dir_deg);
torque.mag_factor = filler.m_SI * params.B / gamma_r;
torque.thermal_factor = sqrt(2 * constants.kB * params.T / gamma_r);
theta = 2 * pi * rand(params.n_fillers, 1);
theta_history = zeros(params.n_fillers, sim.N_steps);
theta_history(:, 1) = theta;

%% 3. Run Euler-Maruyama Simulation Loop
disp('Step 3: Running simulation...');
tic;
for i = 1:(sim.N_steps - 1)
    torque_mag = -torque.mag_factor * sin(2 * (theta - sim.B_dir_rad));
    torque_th = torque.thermal_factor * sqrt(params.dt) * randn(params.n_fillers, 1);
    theta = theta + torque_mag * params.dt + torque_th;
    theta_history(:, i + 1) = theta;
end
elapsed_time = toc;
fprintf('  > Simulation finished in %.2f seconds.\n', elapsed_time);

%% 4. Analyze Results & Predict Capacitance Change with EMT
disp('Step 4: Analyzing results with EMT...');
val_in_sqrt = 1 - 1/p^2;
if DEBUG, fprintf('[DEBUG] Value inside sqrt for eccentricity calc (1 - 1/p^2) = %.4f (Should be positive)\n', val_in_sqrt); end
if val_in_sqrt < 0, error('STOP: p is < 1, leading to complex numbers. Check L and d inputs.'); end
e = sqrt(val_in_sqrt);
if p == 1, N_para = 1/3; else, N_para = (1-e^2)/e^3 * (0.5*log((1+e)/(1-e)) - e); end
N_perp = (1 - N_para) / 2;
if DEBUG, fprintf('[DEBUG] Depolarization Factors: N_parallel = %.4f, N_perpendicular = %.4f\n', N_para, N_perp); end

eps_eff_para = params.eps_matrix * (1 + composite.phi_f * (params.eps_filler - params.eps_matrix) / ...
    (params.eps_matrix + N_para * (1-composite.phi_f) * (params.eps_filler - params.eps_matrix)));
eps_eff_perp = params.eps_matrix * (1 + composite.phi_f * (params.eps_filler - params.eps_matrix) / ...
    (params.eps_matrix + N_perp * (1-composite.phi_f) * (params.eps_filler - params.eps_matrix)));
if DEBUG, fprintf('[DEBUG] Effective Permittivity: eps_parallel = %.2f, eps_perpendicular = %.2f\n', eps_eff_para, eps_eff_perp); end

if DEBUG
    if eps_eff_para < eps_eff_perp
        warning('WARNING: eps_parallel is less than eps_perpendicular. The trend will be negative.');
    else
        disp('[DEBUG] Check passed: eps_parallel > eps_perpendicular, trend should be positive.');
    end
end

S2_vs_time = mean(cos(theta_history - sim.B_dir_rad).^2, 1);
eps_zz_vs_time = eps_eff_perp + (eps_eff_para - eps_eff_perp) * S2_vs_time;
C_change_vs_time = (eps_zz_vs_time - eps_zz_vs_time(1)) ./ eps_zz_vs_time(1) * 100;

if DEBUG
    fprintf('[DEBUG] Order Parameter S2: Initial = %.3f, Final = %.3f\n', S2_vs_time(1), S2_vs_time(end));
    fprintf('[DEBUG] Effective Permittivity eps_zz: Initial = %.3f, Final = %.3f\n', eps_zz_vs_time(1), eps_zz_vs_time(end));
end

%% 5. Plotting Results
disp('Step 5: Generating and saving plots...');
figure('Color', 'w', 'Position', [100, 500, 800, 450]);
plot_indices = round(linspace(1, params.n_fillers, params.n_plot_fillers));
for i = 1:length(plot_indices)
    angle_rad_wrapped = mod(theta_history(plot_indices(i),:) - sim.B_dir_rad + pi/2, pi) - pi/2 + sim.B_dir_rad;
    angle_to_plot_deg = rad2deg(angle_rad_wrapped);
    plot(sim.time, angle_to_plot_deg, 'LineWidth', 2); hold on;
end
title('Alignment Dynamics of Nanorods'); xlabel('Time (s)'); ylabel('Angle (degrees)');
grid on; box on; xlim([0, params.t_final]); ylim([-95, 95]); yticks(-90:30:90);
legend(arrayfun(@(x) sprintf('Rod %d', x), plot_indices, 'UniformOutput', false));
saveas(gcf, 'plot_alignment_dynamics.png');

figure('Color', 'w', 'Position', [950, 500, 800, 450]);
plot(sim.time, C_change_vs_time, 'r-', 'LineWidth', 2.5);
title('Predicted Capacitance Change Over Time'); xlabel('Time (s)');
ylabel('Relative Capacitance Change (vs Initial, %)');
grid on; box on; xlim([0, params.t_final]);
saveas(gcf, 'plot_capacitance_change.png');

disp('--- Simulation Complete ---');