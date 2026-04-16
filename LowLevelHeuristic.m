function [pop,Cost,Gbest,gen,global_fitness,global_position,comm_end_flag] = LowLevelHeuristic(pop,gen,maxgen,algorithm_num,pop_num,lb,ub,dim, ...
    funcid,Cost,Gbest,r,level,max_level,global_fitness,global_position)
%
%pop          -   Population
%gen          -   Current evolutionary generations
%maxgen       -   Max evolutionary generations
%algorithm_num-   The serial number of LLH
%pop_num      -   Population size
%lb,ub        -   Lower and upper bounds of the decision variables
%dim          -   Dimension
%%funcid      -   Function id
%Cost         -   Fitness
%Gbest        -   The optimal solution
%PbestPosition-   Individual historical optimal solution
%PbestCost    -   Individual historical optimal solution fitness
%PbestVel     -   Individual historical optimal solution velocity
%level        -   Evolutionary level of the slave node
%max_level    -   Max Evolutionary level
%Gbest.Cost   -   The optimal fitness
%Gbest.Position-  The optimal decision variables


epsilm=0.05;       % A very small positive number
sample_rate=0.1;   % The proportion of exchanged individuals
sample_num=sample_rate*pop_num;
average_bigin_pop_cost=Gbest.Cost;

%% Calculate population performance
flag=0;
evalute_gap=20;
best_f=Gbest.Cost;
best_solution_not_update_time_begin=gen;

% Use low-level heuristic to evolve until conditions for moving to the next level are met
begin_gen=gen;
begin_tra_gen=gen;
comm_end_flag=0;
while flag==0

    if labProbe(1)
        from_master = labReceive(1);
        if from_master.action==3   % Terminate process
            comm_end_flag=1;
            return;
        end
    end

    switch algorithm_num
        case 1
            % Gorilla Troops Optimizer (GTO) **** Good global search capability 1
            [pop,Cost,Gbest]=GTO_parallel(pop_num,maxgen,lb,ub,dim,funcid,pop,Cost,Gbest,gen);
            gen=gen+2;
        case 2
            % Crayfish Optimization Algorithm (COA)  **** Fast convergence 2
            [pop,Cost,Gbest,global_fitness,global_position]=COA_parallel(pop_num,gen,maxgen,lb,ub,dim,funcid,pop,Cost,Gbest,global_fitness,global_position);
            gen=gen+1;
        case 3
            % Prairie Dog Optimization algorithm (PDO) - Fast convergence
            [pop,Cost,Gbest]=PDO_parallel(pop_num,gen,maxgen,lb,ub,dim,pop,Cost,funcid,Gbest);
            gen=gen+1;
        case 4
            % ADE: Advanced Differential Evolution   *** Good global search capability
            [pop,Cost,Gbest]=ADE_parallel(pop,Cost,pop_num,lb,ub, dim, maxgen,gen,Gbest,funcid);
            gen=gen+1;
        case 5
            % Whale Optimization Algorithm (WOA) - Fast convergence ***
            [pop,Cost,Gbest]=WOA_parallel(pop_num,maxgen,lb,ub,pop,Cost,Gbest,gen,funcid);
            gen=gen+1;
        case 6
            % Composite Differential Evolution (CDE)  ***** Good global search capability
            [pop,Cost,Gbest]=CDE_parallel(pop,Cost,lb,ub,gen,maxgen,Gbest,funcid);
            gen=gen+1;
    end

    if mod(gen,evalute_gap)==0   % The timing condition is met.
        % The number of generations that the statistical worker has evolved in this process
        best_solution_not_update_time=gen-best_solution_not_update_time_begin;
        if Gbest.Cost<best_f   % If the optimal solution has updated, send some individuals to the master node
            C_Position=[];
            C_Cost=[];
            tran_rate=(begin_tra_gen-gen)/(10*evalute_gap);
            if rand<tran_rate
                begin_tra_gen=gen;
                index=randi(pop_num,1,sample_num);
                C_Position=pop(index,:);
                C_Cost=Cost(index);
                C_Position(sample_num,:)=Gbest.Position;
                C_Cost(sample_num,:)=Gbest.Cost;
            end

            best_f=Gbest.Cost;
            slave_info = struct('action',0,'Gbest',Gbest,'best_solution_not_update_time',best_solution_not_update_time,'C_Position',C_Position,'C_Cost',C_Cost);
            best_solution_not_update_time_begin=gen;
            labSend(slave_info,1)
        end

        run_gen=gen-begin_gen;
        [flag]=satifyConditionsToNextLevel(pop,pop_num,r,level,max_level,best_solution_not_update_time,run_gen,maxgen);   % Determine whether conditions for moving to the next level are satisfied

    end
end

% Evaluate performance based on the improvement of the optimal solution
average_end_pop_cost=Gbest.Cost;
strategy_performance=(average_bigin_pop_cost-average_end_pop_cost)/(average_bigin_pop_cost+epsilm);
strategy_performance=max([strategy_performance epsilm]);  % Calculate evolutionary performance
slave_info = struct('action',1,'Gbest',Gbest,'strategy_performance',strategy_performance,'run_gen',gen-begin_gen);
labSend(slave_info,1);

end