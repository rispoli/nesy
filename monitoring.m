function [outputs, satifying_run] = monitoring(trace, IH, get_HO, theta_H, theta_O, obs_range, a_min, beta, forbidden_state_mask)
    outputs = [];

    [n_traces, n_io_atoms] = size(trace);
    trace = [trace; -1 * ones(1, n_io_atoms)];
    previous_output = zeros(1, n_io_atoms);

    for i = 1:n_traces
        input = combine(previous_output, trace(i, :), obs_range);
        HO = get_HO(trace(i + 1, :), obs_range);
        step = consistent_feedforward(input, IH, HO, theta_H, theta_O, obs_range, a_min, beta);
        outputs = [outputs; step > a_min];
        previous_output = (step > a_min) + (-1 * (step <= a_min));
    end

    satifying_run = !unsatisfying_run(previous_output, forbidden_state_mask, a_min);
end

function y = combine(input, trace, obs_range)
    rules_output = input(:, 1:(obs_range(1) - 1)) .+ trace(:, 1:(obs_range(1) - 1));

    obs_output = -1 * ones(1, obs_range(2) - obs_range(1) + 1);
    for i = obs_range(1):obs_range(2)
        if input(i) == -1 && trace(i) == -1
            obs_output(i - obs_range(1) + 1) = -1;
        elseif input(i) == -1 && trace(i) == 1
            obs_output(i - obs_range(1) + 1) = 1;
        elseif input(i) == 1 && trace(i) == -1
            obs_output(i - obs_range(1) + 1) = 1;
        elseif input(i) == 1 && trace(i) == 1
            obs_output(i - obs_range(1) + 1) = 1;
        elseif input(i) == 0
            obs_output(i - obs_range(1) + 1) = trace(i);
        end
    end

    y = [rules_output, obs_output];
end

% y = true = 1 -> unsatisfying run
% y = false = 0 -> satisfying run
function y = unsatisfying_run(M, forbidden_state_mask, a_min)
    [rows, cols] = size(M);
    an_batch = [];

    % Take only the forbidden neurons
    for i = 1:rows
        an_row = [];
        for j = 1:length(forbidden_state_mask)
            if forbidden_state_mask(j)
                an_row = [an_row M(i, j)];
            end
        end
        an_batch = [an_batch; an_row];
    end

    active_neurons = an_batch > a_min;
    y = true;

    for i = 1:size(active_neurons)(1)
        row = false;
        for j = 1:size(active_neurons)(2)
            row = or(row, active_neurons(i, j));
        end
        y = and(y, row);
    end
end