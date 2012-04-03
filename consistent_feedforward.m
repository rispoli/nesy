function y = consistent_feedforward(Input, IH, HO, theta_H, theta_O, obs_range, a_min, beta)
    inconsistent_input = consistency_check(Input(:, obs_range(1):obs_range(2)), a_min);
    if inconsistent_input
        error('Path-generated inconsistency');
    end

    theta_H = inflate_threshold(Input(:, 1:2:(obs_range(1) - 1)), theta_H, a_min);
    output_H = h(threshold(Input * IH, theta_H), beta);

    output_O = h(threshold(output_H * HO, theta_O), beta);

    inconsistent_output = consistency_check(output_O, a_min);
    if inconsistent_input
        error('Rule-generated inconsistency');
    end

    y = output_O;
end

function i_theta = inflate_threshold(previous_output, theta, a_min)
    i_theta = ones(size(theta));
    keeper = previous_output > a_min;
    for i = 1:size(keeper)(2)
        if keeper(i)
            i_theta(i) = theta(i);
        else
            i_theta(i) = Inf;
        end
    end
end

function y = threshold(x, t)
    y = (x > t) .* x;
end

% Bipolar semi-linear activation function.
% beta is the steepness parameter that defines the slope of h(x)
function y = h(x, beta)
    y = (2 ./ (1 + exp(-beta * x))) - 1;
end
