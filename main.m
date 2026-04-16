%% ==========================================================================
%Authors: Shaomiao Chen, Beilei Mo
%Description of ESA-APHOA:
%    1. A master-slave asynchronous communication architecture
%    2. Hyper-heuristic scheduling framework
%Declaration:
%    1. The program entry point is main.m
%    2. This experiment was run on the public computing power service platform(Linux) initiated and constructed by Hunan University of Science and Technology in 2023.
%% ==========================================================================

function main(varargin)

addpath(genpath(pwd));

%% Load parameters
p = inputParser;

addParameter(p, 'n_cores',  24,  @(x) isnumeric(x) && x > 0);      % n_cores: number of parallel cores
addParameter(p, 'n_evals', 24000000, @(x) isnumeric(x) && x > 0);  % n_evals: The max function evaluations(FEs)
addParameter(p, 'func_s',1, @(x) isnumeric(x) && x > 0);           % func_s - func_e: The range of function numbers to be evaluated (CEC2013 LSGO Benchmark Suites)
addParameter(p, 'func_e',1, @(x) isnumeric(x) && x > 0);
addParameter(p, 'nl',1,  @(x) isnumeric(x) && x > 0);              % nl: Number of program executions
addParameter(p, 'd',1,  @(x) isnumeric(x) && x > 0);               % d: The difference in the size of the elite solution sets between two adjacent layers of the tower model

parse(p, varargin{:});

num_cores = p.Results.n_cores;
allFEs = p.Results.n_evals;
f_start = p.Results.func_s;
f_end = p.Results.func_e;
nl = p.Results.nl;
d = p.Results.d;

pop_num = 40;                               % Pop size
Max_Fes=allFEs;                             % Max FEs
max_gen=Max_Fes/pop_num;                    % Max iterations
llh_num=6;                                  % The number of LLHs
slave_max_gen=Max_Fes/pop_num/(num_cores-1);% Max iterations of each worker
fprintf("core is %d ,fes is %d, %d-%d, %d times , d is %d \n",num_cores,allFEs,f_start,f_end,nl,d);
%%

%% Starting the parallel pool
if isempty(gcp('nocreate'))
    parpool('local', num_cores);
else
    delete(gcp('nocreate'));
    parpool('local', num_cores);
end
%%

%%
for funcid = f_start:f_end
    for t_time = 1:nl
        tic;   % Timer

        % Initiate the towel model
        [mode,level_elit_solution,record_cores_imfor,save_queue]=mode_initiation(funcid,d,num_cores,llh_num,pop_num);

        spmd
            if labindex == 1    % labindex is the worker's identification number in SPMD, labindex = 1 means this worker is the master
                highLevelHeuristic(record_cores_imfor,mode,num_cores,level_elit_solution,max_gen,save_queue,pop_num,funcid,t_time);
            else    % The program of workers
                comm_end_flag = 0;
                while ~comm_end_flag    % Main loop: continue until termination criterion is met
                    if labProbe(1)
                        from_master = labReceive(1);

                        if from_master.action==3    % Terminate the process
                            comm_end_flag=1;
                        else
                            if from_master.action==0  % The message for Initiating the population in worker
                                [pop,Cost,dim,ub,lb,Gbest]=pop_initiation(pop_num,funcid);
                                % disp(['Initialize successfully: ', num2str(labindex)]);
                                global_fitness=[];
                                global_position=[];
                                gen=0;
                            end

                            % Received the individuals sent by the master node
                            if ~isempty(from_master.C_Position)
                                S_Position=from_master.C_Position;
                                S_Cost=from_master.C_Cost;
                                len_S_Cost=length(S_Cost);
                                index=randperm(pop_num,len_S_Cost);
                                pop(index,:)=S_Position;
                                Cost(index)=S_Cost;

                                % Update the Gbest
                                [~,fag]=min(Cost);
                                Gbest.Position=pop(fag,:);
                                Gbest.Cost=Cost(fag);
                            end

                            algorithm_num=from_master.strategy_num;    %update the LLH used next
                            %sprintf('The level of worker %d is %d', labindex,1);
                            level=from_master.slave_level;    %update the evolutionary stage

                            r=mode.r_value(level);

                            [pop,Cost,Gbest,gen,global_fitness,global_position,comm_end_flag]= LowLevelHeuristic(pop,gen,slave_max_gen,algorithm_num,pop_num,lb,ub,dim, ...
                                funcid,Cost,Gbest,r,level,mode.level_num,global_fitness,global_position);
                        end

                    end
                end
            end
        end
        runtime = toc;
        fprintf("core_%d ,d_%d, funcid_%d, %d , runtime is %f\n",num_cores,d,funcid,t_time,runtime);
    end
end

end
