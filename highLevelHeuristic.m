function highLevelHeuristic(record_cores_imfor,mode,core_num,level_elit_solution,max_gen,save_queue,pop_num,funcid,t_time)

% mode = struct('level_num',h, ...                                                % Record the information of tower model 
%     'best_f',inf, ...                                                           % Record best solution performance
%     'learn_number',learn_number,...                                             % Learning period
%     'best_p',zeros(1,dim), ...                                                  % Record best solution
%     'level_elit_solution_num',level_elit_solution_num, ...                      % Record number of elite solutions in each level
%     'level_cors_num',zeros(1,h),...                                             % Record number of slave nodes running in each level
%     'record_llh_selected_time',record_llh_selected_time, ...                    % Record selection times of low-level heuristics in each level
%     'record_llh_selected_perfor',record_llh_selected_performance, ...           % Record performance of low-level heuristics in each level
%     'r_value',r_value, ...                                                      % Hypercube radius upper bound for different levels
%     'record_llh_selected_probability',record_llh_selected_probability);         % Record selection probability of low-level heuristics in each level

low_level_heuristic_number=6;
mast_to_slave_inf = struct('action',0,'C_Position',[],'C_Cost',[],'strategy_num',0,'slave_level',1);

%% Send the initialization messages to the workers
for y = 2:core_num
    h=1;
    mast_to_slave_inf.strategy_num=randi(low_level_heuristic_number);
    % Update the selection count of this strategy in the current level
    mode.record_llh_selected_time(h,mast_to_slave_inf.strategy_num)=mode.record_llh_selected_time(h,mast_to_slave_inf.strategy_num)+1;
    % Record information of the slave node
    record_cores_imfor(y,1)=h;
    record_cores_imfor(y,2)=mast_to_slave_inf.strategy_num;
    labSend(mast_to_slave_inf,y);   % Send message to slave process to initialize population
    mode.level_cors_num(h)=mode.level_cors_num(h)+1; 
end
%%

total_gen=1;
len=max_gen/40;
result=zeros(len,2);

record_queue_infor=zeros(1,core_num);  % Record how many times each parallel core enters the queue
max_inter_queue_num=3;

probality_rescord=zeros(1000,8);  % LLHs selection probability iterative data recording matrix
rescord_id=1;
for i=1:mode.level_num
    probality_rescord(rescord_id,:)=[0 i mode.record_llh_selected_probability(i,:)];
    rescord_id=rescord_id+1;
end

while total_gen<=max_gen   %While total generations of all workers are less than max generation
    for y=2:core_num
        if labProbe(y)  %% Check if slave node y has sent a message
            %sprintf('Received message from slave node %d', y)

            slave_info = labReceive(y);  % Receive message from slave node y
            % Update recorded information
            action=slave_info.action;

            if action==0    % Optimal solution transmission
                total_gen=total_gen+slave_info.best_solution_not_update_time;
                % disp(total_gen);
                if  slave_info.Gbest.Cost<mode.best_f  %% Record best solution
                    mode.best_f=slave_info.Gbest.Cost;
                    mode.best_p=slave_info.Gbest.Position;
                    result(i,1)=total_gen;
                    result(i,2)=mode.best_f;
                    i=i+1;
                    % disp(record_cores_imfor);
                    %sprintf("Level %d strategy: %d executed for %d generations, best solution: %d",record_cores_imfor(y,1),record_cores_imfor(y,2),total_gen,mode.best_f)
                end

                % When communication information includes interaction info and current queue size is less than maximum capacity
                if ~isempty(slave_info.C_Position) && record_queue_infor(y)<max_inter_queue_num
                    len=length(slave_info.C_Cost);
                    if save_queue.size>=save_queue.capacity
                        [value,save_queue] = dequeue(save_queue,len) ;
                        record_queue_infor(value)=record_queue_infor(value)-1;
                    end
                    save_queue = enqueue(save_queue,slave_info.C_Position, slave_info.C_Cost,len);
                    record_queue_infor(y)=record_queue_infor(y)+1;
                end
            else  % Slave node level updates
                % Update the performance of the used strategy in its level, and the selection probabilities of all strategies in the current level

                h=record_cores_imfor(y,1);
                strategy_num=record_cores_imfor(y,2);
                selected_time=mode.record_llh_selected_time(h,strategy_num);
                old_performance= mode.record_llh_selected_perfor(h,strategy_num);
                new_performance= slave_info.strategy_performance;
                mode.record_llh_selected_perfor(h,strategy_num)= old_performance+(new_performance- old_performance) /selected_time;
                total_performance=sum(mode.record_llh_selected_perfor(h,:));
                mode.record_llh_selected_probability(h,:)=mode.record_llh_selected_perfor(h,:)./total_performance;


                probality_rescord(rescord_id,:)=[total_gen h mode.record_llh_selected_probability(h,:)];
                rescord_id=rescord_id+1;

                % Decrease the number of running nodes in level h by 1
                mode.level_cors_num(h)=mode.level_cors_num(h)-1;

                % Slave node level update, send message to slave node
                best_f=slave_info.Gbest.Cost;
                [mode,level_elit_solution,record_cores_imfor]=slaveNodeMoveToNextLevel(best_f,h,mode,level_elit_solution,y,record_cores_imfor,save_queue,pop_num);

            end
        end
    end
end
disp(mode.record_llh_selected_time);


filename = sprintf('ESA_APHOA_probility_record_func%d.mat',funcid);
save(filename,"probality_rescord");


fprintf("core_%d, funcid_%d, %d, best is %f ,  %.4e \n",core_num,funcid,t_time,mode.best_f,mode.best_f);
filename = sprintf('core%d_ESA_PHHOA_func%d_time%d.mat',core_num,funcid,t_time);
save(filename,"result");
delete(gcp('nocreate'));

%% Notify slave nodes to terminate (action==3)
mast_to_slave_inf=struct('action',3);
for y=2:core_num
    labSend(mast_to_slave_inf,y);   %% Send message to slave process to initialize population
end
