%% Simulation
N_trials = length(t_per_trial);
out = cell(N_trials, 1);

for i = 1 : N_trials
    rng(i)
    timevec = t_per_trial{i};
    v_tilde_out = v_tilde_out_per_trial{i};

    % Repeat the trial two times and cut-off later the initial transient
    timevec = [timevec; timevec + timevec(end) + timevec(2) - timevec(1)];
    v_tilde_out = [v_tilde_out; v_tilde_out];
    N_data = length(v_tilde_out);

    v_tilde_out = timeseries(v_tilde_out, timevec);

    % To ensure repeatability, generate the rotational speed measurement
    % noise
    eta = omega_in_noise_mean + sqrt(omega_in_noise_variance) * randn([N_data, 1]);
    eta = timeseries(eta, timevec);

    % Generate the noise affecting the optical sensors
    % To ensure repeatability, we use the same noise for both the winding
    % and unwinding dynamics
    % Particularly, we can easily generate xi_out directly from
    % v_tilde_out, which is available
    xi_in = pseudo_bernoulli(v_tilde_out.Data, p_in);
    xi_in = timeseries(xi_in, timevec);
    xi_out = pseudo_bernoulli(v_tilde_out.Data, p_out);
    xi_out = timeseries(xi_out, timevec);

    t_max_sim = timevec(end);

    set_param(simulink_name, 'Solver', 'ode45', ...
        'StartTime', num2str(timevec(1)), ...
        'StopTime', num2str(timevec(end)))
    out{i} = sim(simulink_name, 'ReturnWorkspaceOutputs', 'on', ...
        'SrcWorkspace', 'current');
end

%% Signal extraction and processing
t_sim = cell(N_trials, 1);
y_r = cell(N_trials, 1);
y_r_vs = cell(N_trials, 1);
v_tilde_in = cell(N_trials, 1);
v_tilde_out = cell(N_trials, 1);
m_in = cell(N_trials, 1);
m_out = cell(N_trials, 1);
m_res = cell(N_trials, 1);
omega_in = cell(N_trials, 1);
omega_in_m = cell(N_trials, 1);
omega_in_bar = cell(N_trials, 1);
yarn_accumulation = cell(N_trials, 1);
yarn_supply_finished = cell(N_trials, 1);
controller_signals = cell(N_trials, 1);

for i = 1 : N_trials
    t_sim{i} = out{i}.y_r.Time;
    y_r{i} = squeeze(out{i}.y_r.Data);
    y_r_vs{i} = squeeze(out{i}.y_r_vs.Data);
    v_tilde_in{i} = squeeze(out{i}.v_tilde_in.Data);
    v_tilde_out{i} = squeeze(out{i}.v_tilde_out.Data);
    m_in{i} = squeeze(out{i}.m_in.Data);
    m_out{i} = squeeze(out{i}.m_out.Data);
    m_res{i} = squeeze(out{i}.m_res.Data);
    omega_in{i} = squeeze(out{i}.omega_in.Data);
    omega_in_m{i} = squeeze(out{i}.omega_in_m.Data);
    omega_in_bar{i} = squeeze(out{i}.omega_in_bar.Data);
    yarn_accumulation{i} = squeeze(out{i}.yarn_accumulation.Data);
    yarn_supply_finished{i} = squeeze(out{i}.yarn_supply_finished.Data);
    controller_signals{i} = squeeze(out{i}.controller_signals.Data);
    if size(controller_signals, 1) < size(controller_signals, 2)
        controller_signals{i} = controller_signals';
    end

    % Cut-out initial transient during which the negative yarn feeder is set in
    % motion (not of intereset)
    N_data = length(t_sim{i});
    t_sim{i} = t_sim{i}(N_data/2 + 1 : end);
    t_sim{i} = t_sim{i} - t_sim{i}(1);
    y_r{i} = y_r{i}(N_data/2 + 1 : end);
    y_r_vs{i} = y_r_vs{i}(N_data/2 + 1 : end);
    v_tilde_in{i} = v_tilde_in{i}(N_data/2 + 1 : end);
    v_tilde_out{i} = v_tilde_out{i}(N_data/2 + 1 : end);
    m_in{i} = m_in{i}(N_data/2 + 1 : end);
    m_out{i} = m_out{i}(N_data/2 + 1 : end);
    m_res{i} = m_res{i}(N_data/2 + 1 : end);
    omega_in{i} = omega_in{i}(N_data/2 + 1 : end);
    omega_in_m{i} = omega_in_m{i}(N_data/2 + 1 : end);
    omega_in_bar{i} = omega_in_bar{i}(N_data/2 + 1 : end);
    yarn_accumulation{i} = yarn_accumulation{i}(N_data/2 + 1 : end);
    yarn_supply_finished{i} = yarn_supply_finished{i}(N_data/2 + 1 : end);
    controller_signals{i} = controller_signals{i}(N_data/2 + 1 : end, :);
end

%% Max/min of each signal
y_r_min = min(cell2mat(y_r));
y_r_max = max(cell2mat(y_r));
y_r_vs_min = min(cell2mat(y_r_vs));
y_r_vs_max = max(cell2mat(y_r_vs));
v_tilde_in_min = min(cell2mat(v_tilde_in));
v_tilde_in_max = max(cell2mat(v_tilde_in));
v_tilde_out_min = min(cell2mat(v_tilde_out));
v_tilde_out_max = max(cell2mat(v_tilde_out));
omega_in_min_lb = min(cell2mat(omega_in));
omega_in_max_ub = max(cell2mat(omega_in));
omega_in_bar_min = min(cell2mat(omega_in_bar));
omega_in_bar_max = max(cell2mat(omega_in_bar));