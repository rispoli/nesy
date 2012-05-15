function y = consistent_feedforward(Input, IH, HO, theta_H, theta_O, obs_range, a_min, beta)
    output_H = h(threshold(Input * IH, theta_H), beta);

    output_O = h(threshold(output_H * HO, theta_O), beta);

    inconsistent_output = consistency_check(output_O, a_min);
    if inconsistent_output
        error('Rule-generated inconsistency');
    end

    y = output_O;
end

function y = threshold(x, t)
    y = x - t;
end

% Bipolar semi-linear activation function.
% beta is the steepness parameter that defines the slope of h(x)
function y = h(x, beta)
    y = (2 ./ (1 + exp(-beta * x))) - 1;
end
