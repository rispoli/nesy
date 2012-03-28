function y = consistent_feedforward(Input, IH, HO, theta_H, theta_O, obs_range, a_min, beta)
    inconsistent_input = consistency_check(Input(:, obs_range(1):obs_range(2)), a_min);
    if inconsistent_input
        error ("Path-generated inconsistency");
    end

    theta_H = inflate_threshold(Input(:, 1:2:(obs_range(1) - 1)), theta_H, a_min);
    output_H = h(threshold(Input * IH, theta_H), beta);

    output_O = h(threshold(output_H * HO, theta_O), beta);

    inconsistent_output = consistency_check(output_O, a_min);
    if inconsistent_input
        error ("Rule-generated inconsistency");
    end

    y = output_O;
end

% y = true = 1 -> inconsistent result
% y = false = 0 -> consistent result
function y = consistency_check(M, a_min)
    y = cons_or(pairwise_and(M > a_min));
end

function y = pairwise_and(M)
    [cols, rows] = size(M);
    y = [];

    for i = 1:cols
        and_row = [];
        for j = 1:2:rows
            and_row = [and_row and(M(i, j), M(i, j + 1))];
        end
        y = [y; and_row];
    end
end

function y = cons_or(M)
    [cols, rows] = size(M);
    y = false;

    for i = 1:cols
        or_row = false;
        for j = 1:rows
            or_row = or(or_row, M(i, j));
        end
        y = or(y, or_row);
    end
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
