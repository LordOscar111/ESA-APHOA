function [mode,level_elit_solution,record_cores_imfor]=slaveNodeMoveToNextLevel(best_f,h,mode,level_elit_solution,slave_number,record_cores_imfor,save_queue,pop_num)

alf=0.9;
flag=0;
if h<mode.level_num
    % Check if there is a worse elite solution in the current level's elite set
    if ~isempty(find(level_elit_solution{h}>best_f,1))
        [~,index]=max(level_elit_solution{h});
        level_elit_solution{h}(index)=best_f;
        flag=1;
    else
        % Higher levels have lower probability of moving to the next level
        if rand()<alf^h
            flag=1;
        end
    end
end

mast_to_slave_inf=struct('action',0,'strategy_num',0,'slave_level',1,'C_Position',[],'C_Cost',[]);

if flag==0
    % Fail to advance, restart population
    h=1;
    mast_to_slave_inf.action=0;
    num=pop_num*0.5;

else
    % Move to the next level
    h=h+1;
   % sprintf("Entering level %d",h)
    mast_to_slave_inf.slave_level=h;
    mast_to_slave_inf.action=1;
    num=pop_num*0.1;
end
[S_Position,S_Cost]=queueSample(save_queue,num);
mast_to_slave_inf.C_Position=S_Position;
mast_to_slave_inf.C_Cost=S_Cost;
% Update the number of running slave nodes in each level
mode.level_cors_num(h)=mode.level_cors_num(h)+1;
% Record slave node information
record_cores_imfor(slave_number,1)=h;

if mode.learn_number(h)>0
    mode.learn_number(h)=mode.learn_number(h)-1;
    selected_strategy_number=record_cores_imfor(slave_number,2);
else
    selected_strategy_number=roulette_wheel_selection(mode.record_llh_selected_probability(h,:));
    record_cores_imfor(slave_number,2)=selected_strategy_number;
end

% Update the application count of the selected strategy for this level
mode.record_llh_selected_time(h,selected_strategy_number)=mode.record_llh_selected_time(h,selected_strategy_number)+1;
% Master to slave message structure
mast_to_slave_inf.strategy_num=selected_strategy_number;
% Send message to slave node
labSend(mast_to_slave_inf,slave_number);
