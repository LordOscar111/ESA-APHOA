function [X,OBest,Gbest]=PDO_parallel(pop_size,gen,maxgen,LB,UB,Dim,X,OBest,funcid,Gbest)
%% 草原犬鼠优化算法 (Prairie Dogs Optimization, PDO)
% 用于求解无约束优化问题的元启发式算法
% 参考文献: Ezugwu, A. E., Agushaka, J. O., & Atangana, A. (2021).
% Prairie dogs optimization: A nature-inspired metaheuristic algorithm for engineering optimization problems. Neural Computing and Applications, 1-21.
% [pop,Cost,Gbest]=PDO1__parr(pop_size,gen,maxgen,lb,ub,dim,prairie_dogs,fitness,funcid,Gbest);
% function [best_position, best_fitness, convergence_curve] = PDO(objective_func, dim, lb, ub, pop_size, max_iter)
% 输入参数:
% objective_func - 目标函数句柄
% dim - 问题维度
% lb, ub - 搜索空间下界和上界
% pop_size - 种群大小(草原犬鼠数量)
% max_iter - 最大迭代次数

% 输出参数:
% best_position - 最优解位置
% best_fitness - 最优适应度值
% convergence_curve - 收敛曲线


%% 找到初始全局最优
PDBest_P=Gbest.Position;           % best positions
Best_PD=Gbest.Cost;                    % global best fitness
if gen>maxgen
  t=maxgen;  
else
   t=gen;    
end

%t=gen;
T=maxgen;
M=Dim;
N=pop_size;
%set number of coteries


Xnew=zeros(N,Dim);
CBest=zeros(1,N);     % new fitness values


rho=0.005;                   % account for individual PD difference
% eps                         %food source quality
epsPD=0.1;                  % food source alarm


if mod(t,2)==0
    mu=-1;
else
    mu=1;
end
DS=1.5*randn*(1-t/T)^(2*t/T)*mu;  % Digging strength
PE=1.5*(1-t/T)^(2*t/T)*mu;  % Predator effect
RL=levym(N,Dim,1.5);     % Levy random number vector
TPD=repmat(PDBest_P,N,1); %Top PD
for i=1:N
    for j=1:M

        if (t<T/4)
            cpd=rand*((TPD(i,j)-X(randi([1 N]),j)))/((TPD(i,j))+eps);
            P=rho+(X(i,j)-mean(X(i,:)))/(TPD(i,j)*(UB-LB)+eps);
            eCB=PDBest_P(1,j)*P;
            Xnew(i,j)=PDBest_P(1,j)-eCB*epsPD-cpd*RL(i,j);
        elseif (t<2*T/4 && t>=T/4)
            Xnew(i,j)=PDBest_P(1,j)*X(randi([1 N]),j)*DS*RL(i,j);
        elseif (t<3*T/4 && t>=2*T/4)
            Xnew(i,j)=PDBest_P(1,j)*PE*rand;
        else
            cpd=rand*((TPD(i,j)-X(randi([1 N]),j)))/((TPD(i,j))+eps);
            P=rho+(X(i,j)-mean(X(i,:)))/(TPD(i,j)*(UB-LB)+eps);
            eCB=PDBest_P(1,j)*P;
            Xnew(i,j)=PDBest_P(1,j)-eCB*eps-cpd*rand;
        end
    end

    Flag_UB=Xnew(i,:)>UB; % check if they exceed (up) the boundaries
    Flag_LB=Xnew(i,:)<LB; % check if they exceed (down) the boundaries
    Xnew(i,:)=(Xnew(i,:).*(~(Flag_UB+Flag_LB)))+UB.*Flag_UB+LB.*Flag_LB;
    CBest(1,i)= benchmark_func(Xnew(i,:)', funcid);
    % CBest(1,i)=F_obj(Xnew(i,:));
    if CBest(1,i)<OBest(1,i)
        X(i,:)=Xnew(i,:);
        OBest(1,i)=CBest(1,i);
    end
    if OBest(1,i)<Best_PD
        Best_PD=OBest(1,i);
        PDBest_P=X(i,:);
    end
end

Gbest.Cost=Best_PD;
Gbest.Position=PDBest_P;
end







function [z] = levym(n,m,beta)

num = gamma(1+beta)*sin(pi*beta/2); % used for Numerator

den = gamma((1+beta)/2)*beta*2^((beta-1)/2); % used for Denominator

sigma_u = (num/den)^(1/beta);% Standard deviation

u = random('Normal',0,sigma_u,n,m);

v = random('Normal',0,1,n,m);

z =u./(abs(v).^(1/beta));
end
