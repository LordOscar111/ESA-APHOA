function [flag]=satifyConditionsToNextLevel(pop,pop_size,r,level,max_level,best_solution_not_update_time,run_gen,maxgen)

% flag = 1: condition satisfied to enter next level
% flag = 0: condition not satisfied to enter next level

max_run_gen=(0.8*maxgen)/max_level;
max_best_solution_not_update_time=maxgen*0.01;

%% Parameter settings
sample_size = pop_size*0.25; 

%% Random sampling
rand_sample = randperm(pop_size, sample_size);
sampled_pop = pop(rand_sample, :);
mean_particle = mean(pop, 1);      % Find the mean value for each dimension
dim_max = max(sampled_pop, [], 1); % Find the maximum value for each dimension
dim_min = min(sampled_pop, [], 1); % Find the minimum value for each dimension

%% Check each particle

% Calculate the absolute difference between current particle and mean (per dimension)
abs_diff = max(abs(dim_max - mean_particle), abs(dim_min - mean_particle)); % 1×dim

%% Check if all dimensions are within the radius
if any(abs_diff>r)
    flag = 0;
else
    flag = 1;
end

if run_gen>=max_run_gen && level<max_level
    flag = 1;
end

if level==max_level
    if best_solution_not_update_time>=max_best_solution_not_update_time
        flag = 1;
    else
        flag = 0;
    end
end

end
