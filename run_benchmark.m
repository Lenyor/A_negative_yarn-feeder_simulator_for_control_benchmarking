%% Setup
clc
clear
close all

addpath('support')
addpath('controllers')

set_up_parameters_for_simulink

% Reference your controller in Simulink
your_controller_name = 'baseline_controller';
set_param([simulink_name, '/Controller/Your_controller'], ...
    'ReferencedSubsystem', your_controller_name);
% Run the script which sets the parameters of your controller
baseline_controller_parameters

%% Run simulation
simulate_all_experiments_and_extract_signals

%% Check if controller is valid based on the alarms
yarn_accumulation_flags = nan(N_trials, 1);
yarn_supply_finished_flags = nan(N_trials, 1);
for i = 1 : N_trials
    yarn_accumulation_flags(i) = any(yarn_accumulation{i});
    yarn_supply_finished_flags(i) = any(yarn_supply_finished{i});
end

if any(yarn_accumulation_flags)
    warning('Control attempt failed: yarn accomulation scenario')
end
if any(yarn_supply_finished_flags)
    warning('Control attempt failed: yarn supply finished scenario')
end

%% Visualization - setup
linewidth = 2;

set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot, 'DefaultAxesFontSize', 16)

simplified_visualization = 0;

%% Visualization (1)
for i = 1 : N_trials
    fig = figure('WindowStyle', 'docked');
    fig.Name = trial_names{i};
    tiledlayout(2, 1, 'TileSpacing', 'compact')
    axes = nexttile;
    plot(t_sim{i}, y_r{i}, ':', ...
        'LineWidth', linewidth)
    hold on
    stairs(t_sim{i}, y_r_vs{i}, ...
        'LineWidth', linewidth)
    yline(0, 'k', 'LineWidth', linewidth, 'Alpha', 1)
    visualizeAlarms(t_sim{i}, yarn_accumulation{i}, yarn_supply_finished{i}, ...
        [min([y_r_min, y_r_vs_min]), max([y_r_max, y_r_vs_max])], ...
        simplified_visualization)
    ylabel('Number of windings')
    legend({'$y_{\mathrm{r}}(t)$', '$y_{\mathrm{r, vs}}(t)$', '$\bar{y}_{\mathrm{r}}(t)$'}, ...
        'Location', 'best')
    grid on
    ylim([min([y_r_min, y_r_vs_min]), max([y_r_max, y_r_vs_max])])
    title(trial_names{i})

    axes = [axes, nexttile];
    plot(t_sim{i}, v_tilde_out{i}, ...
        'LineWidth', linewidth)
    hold on
    plot(t_sim{i}, v_tilde_in{i}, ...
        'LineWidth', linewidth)
    visualizeAlarms(t_sim{i}, yarn_accumulation{i}, yarn_supply_finished{i}, ...
        [min([v_tilde_in_min, v_tilde_out_min]), max([v_tilde_in_max, v_tilde_out_max])], ...
        simplified_visualization)
    ylabel('Velocities [cm/s]')
    legend({'$\tilde{v}_{\mathrm{out}}(t)$', '$\tilde{v}_{\mathrm{in}}(t)$'}, ...
        'Location', 'best')
    grid on
    xlabel('$t$ [s]')
    ylim([min([v_tilde_in_min, v_tilde_out_min]), max([v_tilde_in_max, v_tilde_out_max])])

    linkaxes(axes, 'x')
end

%% Visualization (2)
for i = 1 : N_trials
    fig = figure('WindowStyle', 'docked');
    fig.Name = trial_names{i};
    tiledlayout(3, 1, 'TileSpacing', 'compact')
    axes = nexttile;
    yyaxis left
    plot(t_sim{i}, v_tilde_in{i}, ...
        'LineWidth', linewidth)
    ylabel('$\tilde{v}_{\mathrm{in}}(t)$ [cm/s]')
    ylim([v_tilde_in_min, v_tilde_in_max])
    yyaxis right
    stem(t_sim{i}, m_in{i}, ...
        'LineWidth', linewidth/3)
    ylabel('$m_{\mathrm{in}}(t)$')
    ylim([0 5])
    yticks([0, 1])
    grid on
    title(trial_names{i})

    axes = [axes, nexttile];
    yyaxis left
    plot(t_sim{i}, v_tilde_out{i}, ...
        'LineWidth', linewidth)
    ylabel('$\tilde{v}_{\mathrm{out}}(t)$ [cm/s]')
    ylim([v_tilde_out_min, v_tilde_out_max])
    yyaxis right
    stem(t_sim{i}, m_out{i}, ...
        'LineWidth', linewidth/3)
    ylabel('$m_{\mathrm{out}}(t)$')
    ylim([0 5])
    yticks([0, 1])
    grid on

    axes = [axes, nexttile];
    yyaxis left
    plot(t_sim{i}, y_r{i}, ...
        'LineWidth', linewidth)
    ylabel('$y_{\mathrm{r}}(t)$')
    ylim([y_r_min, y_r_max])
    yline(0, 'k', 'LineWidth', linewidth, 'Alpha', 1)
    yyaxis right
    stem(t_sim{i}, m_res{i}, ...
        'LineWidth', linewidth/3)
    ylabel('$m_{\mathrm{res}}(t)$')
    ylim([0 5])
    yticks([0, 1])
    grid on
    xlabel('$t$ [s]')

    linkaxes(axes, 'x')
end

%% Visualization (3)
for i = 1 : N_trials
    fig = figure('WindowStyle', 'docked');
    fig.Name = trial_names{i};
    stairs(t_sim{i}, omega_in_bar{i}, 'k:', ...
        'LineWidth', linewidth)
    hold on
    plot(t_sim{i}, omega_in_m{i}, '--', ...
        'LineWidth', linewidth/2)
    plot(t_sim{i}, omega_in{i}, ...
        'LineWidth', linewidth)
    xlabel('$t$ [s]')
    ylabel('Rotational speeds [rad/s]')
    legend({'$\bar{\omega}_{\mathrm{in}}(t)$', '$\omega_{\mathrm{in, m}}(t)$', '$\omega_{\mathrm{in}}(t)$'}, ...
        'Location', 'best')
    grid on
    title(trial_names{i})
    ylim([min([omega_in_min, omega_in_bar_min]), max([omega_in_max, omega_in_bar_max])])
end

%% Visualization (4)
for i = 1 : N_trials
    fig = figure('WindowStyle', 'docked');
    fig.Name = trial_names{i};
    stairs(t_sim{i}, y_r{i} - y_r_vs{i}, ...
        'k:', ...
        'LineWidth', linewidth)
    yline(1, 'r--', 'LineWidth', linewidth)
    yline(-1, 'r--', 'LineWidth', linewidth)
    ylabel('$y_{\mathrm{r}}(t) - y_{\mathrm{r, vs}}(t)$')
    xlabel('$t$ [s]')
    grid on
    title(trial_names{i})
    ylim([min([y_r_min, y_r_vs_min]), max([y_r_max, y_r_vs_max])])
end

%% Visualization (5)
figure
tiledlayout(2, 1, 'TileSpacing', 'compact')
axes = nexttile;
bar(1 : 1 : N_trials, yarn_accumulation_flags)
xticks(1 : 1 : N_trials)
xticklabels([])
ylabel('Yarn accumulation')
ylim([0, 1])
grid on

axes = [axes, nexttile];
bar(1 : 1 : N_trials, yarn_supply_finished_flags);
xticks(1 : 1 : N_trials)
ylabel('Yarn supply finished')
ylim([0, 1])
grid on
xticklabels(trial_names)

%% Performance indicators
% Number of windings RMSE
y_r_RMSE = nan(N_trials, 1);
% Smoothness (TV)
omega_in_bar_TV = nan(N_trials, 1);

for i = 1 : N_trials
    y_r_RMSE(i) = sqrt(goodnessOfFit(y_r{i}, zeros(size(y_r{i})), 'MSE'));
    omega_in_bar_TV(i) = sum(abs(diff(omega_in_bar{i})))/(length(omega_in_bar{i}) - 1);
end

figure
tiledlayout(2, 1, 'TileSpacing', 'compact')
axes = nexttile;
bar(1 : 1 : N_trials, y_r_RMSE)
hold on
yline(mean(y_r_RMSE), 'LineWidth', linewidth)
xticks(1 : 1 : N_trials)
xticklabels([])
ylabel('$\psi_{\mathrm{(CO1)}}^{(e)}$ (RMSE of $y_{\mathrm{r}}$)')
ylim([0, max(y_r_RMSE)])
grid on

nexttile
bar(1 : 1 : N_trials, omega_in_bar_TV)
hold on
yline(mean(omega_in_bar_TV), 'LineWidth', linewidth)
xticks(1 : 1 : N_trials)
ylabel('$\psi_{\mathrm{(CO3)}}^{(e)}$ (TV of $\bar{\omega}_{\mathrm{in}}$) [rad/s]')
grid on
xticklabels(trial_names)

fprintf('Worst case RMSE of y_r: %f\n', max(y_r_RMSE))
fprintf('Average case RMSE of y_r: %f\n', mean(y_r_RMSE))
fprintf('Worst case TV of omega_in_bar: %f [rad/s]\n', max(omega_in_bar_TV))
fprintf('Average case TV of omega_in_bar: %f [rad/s]\n', mean(omega_in_bar_TV))

%% Cleanup
rmpath('support')
rmpath('controllers')
