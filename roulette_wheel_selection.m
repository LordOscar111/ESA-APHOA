function selected_strategy = roulette_wheel_selection(selection_pb)
% Check if input is a valid probability distribution
if abs(sum(selection_pb) - 1) > 1e-1
    disp(selection_pb)
    error('Probabilities must sum to 1.');

end

% Calculate cumulative probabilities
cumulative_probabilities = cumsum(selection_pb);

r = rand;    % Generate a random number

% Find the first position where cumulative probability >= random number
selected_strategy = find(cumulative_probabilities >= r, 1);
end