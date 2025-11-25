function xi = pseudo_bernoulli(v_tilde, p_function)
N_data = length(v_tilde);
xi = nan(N_data, 1);
for k = 1 : N_data
    temp = unifrnd(0, 1); % random number between 0 and 1
    % Current success rate
    p = p_function(v_tilde(k));
    if temp > p
        xi(k) = 0;
    else
        xi(k) = 1;
    end
end
end