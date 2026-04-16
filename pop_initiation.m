function [pop,fitness,dim,ub,lb,Gbest]=pop_initiation(pop_num,funcid)

[dim,ub,lb]=selectionDim(funcid);
chaotic_var = rand(pop_num,dim);
chaotic_var = mod(chaotic_var + 0.2-0.5*2*pi*sin(2*pi*chaotic_var),1);
pop=lb+(ub-lb)*chaotic_var;
fitness = benchmark_func(pop', funcid);
[~,index1]=min(fitness);
Gbest.Position=pop(index1,:);
Gbest.Cost=fitness(index1);

end