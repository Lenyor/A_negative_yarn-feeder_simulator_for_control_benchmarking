simulink_name = 'simulink_benchmark';

%% Load data and parameters
params_name = 'mdl_parameters_int';
load(['support', filesep, params_name, '.mat'])

%% Parameters
% Winding dynamics
G_v_tilde_in = tf(mu_v_tilde_in, ...
    [tau_v_tilde_in, 1], 'IODelay', gamma_v_tilde_in);

% Yarn model
A_yarn = 0;
B_yarn = [delta/l, - delta/l];
C_yarn = 1/delta;
D_yarn = [0, 0];
yarn_model_nominal = ss(A_yarn, B_yarn, C_yarn, D_yarn);

% Residual model
res_mdl_params.n_h_tot = sum(res_mdl_params.n_h);
% Simulink does not accept struct arrays with fields different sizes, need
% to explicitly pad them
W_height = nan(res_mdl_params.N_layers, 1);
W_width = nan(res_mdl_params.N_layers, 1);
R_height = nan(res_mdl_params.N_layers, 1);
R_width = nan(res_mdl_params.N_layers, 1);
b_height = nan(res_mdl_params.N_layers, 1);
b_width = nan(res_mdl_params.N_layers, 1);
for j = 1 : res_mdl_params.N_layers
    [W_height(j), W_width(j)] = size(res_mdl_params.W(j).W_h);
    [R_height(j), R_width(j)] = size(res_mdl_params.R(j).R_h);
    [b_height(j), b_width(j)] = size(res_mdl_params.b(j).b_h);
end
res_mdl_params.W_height = W_height;
res_mdl_params.W_width = W_width;
res_mdl_params.R_height = R_height;
res_mdl_params.R_width = R_width;
res_mdl_params.b_height = b_height;
res_mdl_params.b_width = b_width;
for j = 1 : res_mdl_params.N_layers
    temp = res_mdl_params.W(j).W_h;
    res_mdl_params.W(j).W_h = nan(max(W_height), max(W_width));
    res_mdl_params.W(j).W_h(1 : W_height(j), 1 : W_width(j)) = temp;

    temp = res_mdl_params.W(j).W_r;
    res_mdl_params.W(j).W_r = nan(max(W_height), max(W_width));
    res_mdl_params.W(j).W_r(1 : W_height(j), 1 : W_width(j)) = temp;

    temp = res_mdl_params.W(j).W_z;
    res_mdl_params.W(j).W_z = nan(max(W_height), max(W_width));
    res_mdl_params.W(j).W_z(1 : W_height(j), 1 : W_width(j)) = temp;

    temp = res_mdl_params.R(j).R_h;
    res_mdl_params.R(j).R_h = nan(max(R_height), max(R_width));
    res_mdl_params.R(j).R_h(1 : R_height(j), 1 : R_width(j)) = temp;

    temp = res_mdl_params.R(j).R_r;
    res_mdl_params.R(j).R_r = nan(max(R_height), max(R_width));
    res_mdl_params.R(j).R_r(1 : R_height(j), 1 : R_width(j)) = temp;

    temp = res_mdl_params.R(j).R_z;
    res_mdl_params.R(j).R_z = nan(max(R_height), max(R_width));
    res_mdl_params.R(j).R_z(1 : R_height(j), 1 : R_width(j)) = temp;

    temp = res_mdl_params.b(j).b_h;
    res_mdl_params.b(j).b_h = nan(max(b_height), max(b_width));
    res_mdl_params.b(j).b_h(1 : b_height(j), 1 : b_width(j)) = temp;

    temp = res_mdl_params.b(j).b_r;
    res_mdl_params.b(j).b_r = nan(max(b_height), max(b_width));
    res_mdl_params.b(j).b_r(1 : b_height(j), 1 : b_width(j)) = temp;

    temp = res_mdl_params.b(j).b_z;
    res_mdl_params.b(j).b_z = nan(max(b_height), max(b_width));
    res_mdl_params.b(j).b_z(1 : b_height(j), 1 : b_width(j)) = temp;
end
clear W_height W_width R_height R_width b_height b_width

%% Open simulink
open([simulink_name, '.slx'])

if res_mdl_params.useOnlyIntegral
    set_param([simulink_name, '/Plant model/Yarn model'], ...
        'ReferencedSubsystem', 'yarn_model_int');
else
    set_param([simulink_name, '/Plant model/Yarn model'], ...
        'ReferencedSubsystem', 'yarn_model');
end