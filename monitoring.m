function [outputs, satifying_run] = monitoring(trace, IH, get_HO, theta_H, theta_O, obs_range, a_min, beta, forbidden_state_mask)
    outputs = [];

    [n_traces, n_io_atoms] = size(trace);
    trace = [trace; repmat([-1 1], 1, n_io_atoms / 2)];
    previous_output = zeros(1, n_io_atoms);

    for i = 1:n_traces
        input = combine(previous_output, trace(i, :), obs_range, a_min);
        HO = get_HO(trace(i + 1, :), obs_range);
        theta_O = get_theta_O(HO);
        try
            step = consistent_feedforward(input, IH, HO, theta_H, theta_O, obs_range, a_min, beta);
        catch
            i
            input
            rethrow(lasterror);
        end
        outputs = [outputs; step > a_min];
        previous_output = step;
    end

    last_state = combine(previous_output, trace(n_traces, :), obs_range, a_min);
    inconsistent_input = consistency_check(last_state(:, obs_range(1):obs_range(2)), a_min);
    if inconsistent_input
        error('Path-generated inconsistency (last observation set in trace)');
    end
    satifying_run = !unsatisfying_run(previous_output, forbidden_state_mask, a_min);
end

function y = combine(input, trace, obs_range, a_min)
    if input == zeros(size(trace)) % First step
        y = trace;
    else
        for i = obs_range(1):obs_range(2)
            if (input(i) > a_min) == 1 && trace(i) != 1
                error('Obligation does not imply observation');
            end
        end
        obs_output = zeros(1, obs_range(2) - obs_range(1) + 1);
        for i = obs_range(1):2:obs_range(2)
            if trace(i) == 1 && (input(i + 1) > a_min) == 1
                error('Positive observation and negative obligation');
            elseif trace(i + 1) == 1 && (input(i) > a_min) == 1
                error('Negative observation and positive obligation');
            end
            obs_output(i - obs_range(1) + 1) = trace(i);
            obs_output(i - obs_range(1) + 2) = trace(i + 1);
        end
        y = [input(:, 1:(obs_range(1) - 1)), obs_output];
    end
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
