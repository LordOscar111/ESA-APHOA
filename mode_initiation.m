function [mode,level_elit_solution,record_cores_imfor,save_queue]=mode_initiation(funcid,d,numcores,llh_number,pop_num)
  % d - difference between levels
  % Initialize variables
  
    h = 0;
   [dim,ub,lb]=selectionDim(funcid);

    level_elit_solution_num=zeros(numcores,1);
    % Calculate maximum number of levels h
    while true
        h = h + 1; % Increment level count
        if h==1
            numpops = 1;
            level_elit_solution_num(h)=numpops;
        else
            numpops = 1+(h-1)*d;
            level_elit_solution_num(h)=numpops;
        end

        % Check if total population exceeds number of cores
        if numpops > numcores-1
            h = h - 1; % Previous level is the maximum feasible level
            break;
        end
    end

disp("H is " +h);
level_elit_solution_num(h+1:end)=[];
level_elit_solution_num(1:end)=level_elit_solution_num(end:-1:1);
level_elit_solution_num(1)=numcores-1;
level_elit_solution={};


r_value=zeros(1,h);

for i=1:h
    r_value(i)=(ub-lb)*(h-i)/(2*h);
end

for i=1:h
    level_elit_solution{i}=ones(1,level_elit_solution_num(i))*inf;
end
epsilm=0.05; 
record_llh_selected_time=ones(h,llh_number);
record_llh_selected_performance=ones(h,llh_number).*epsilm;
record_llh_selected_probability=ones(h,llh_number).*(1/llh_number);

record_cores_imfor=zeros(numcores,2);  % Slave node info: column 1 - level, column 2 - selected strategy 
learn_number=ones(h,1)*llh_number;

sample_rate=0.1;
sample_num=2*sample_rate*pop_num;

save_queue = CircularQueue(numcores*sample_num,dim);



mode = struct('level_num',h, ...                                                  % Record number of levels
              'learn_number',learn_number, ...                                    % Learning period
              'best_f',inf, ...                                                   % Record best solution performance
              'best_p',zeros(1,dim), ...                                          % Record best solution
              'level_cors_num',zeros(1,h), ...                                    % Record number of slave nodes running in each level
              'level_elit_solution_num',level_elit_solution_num, ...              % Record number of elite solutions in each level
              'record_llh_selected_time',record_llh_selected_time, ...            % Record selection times of low-level heuristics in each level
              'record_llh_selected_perfor',record_llh_selected_performance, ...   % Record performance of low-level heuristics in each level
              'r_value',r_value, ...                                              % Hypercube radius upper bound for different levels
              'record_llh_selected_probability',record_llh_selected_probability); % Record selection probability of low-level heuristics in each level