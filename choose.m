function y = choose(alternatives, observation, obs_range)
    ob = observation(:, obs_range(1):obs_range(2));
    al = alternatives(:, obs_range(1):obs_range(2));

    obs_sum = choice = 0;
    for i = 1:size(alternatives)(1)
        v = (ob > 0) .* al(i, :);
        if sum(v) > obs_sum
            obs_sum = sum(v);
            choice = i;
        end
    end

    if choice
        y = alternatives(choice, :);
    else
        y = alternatives(randi(size(alternatives)(1)), :);
    end
end
