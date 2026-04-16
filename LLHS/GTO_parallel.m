function [X,Pop_Fit,Gbest]=GTO_parallel(pop_size,max_iter,lower_bound,upper_bound,variables_no,funcid,Position,Cost,Gbest,g)


% pop_size:种群规模
% max_iter：最大迭代次数
% lower_bound :下边界
% upper_bound：上边界
% variables_no：维度
% funcid：优化问题编号
% Position:种群
% Cost：种群适应度值
% Gbest：最优解
% g：当前迭代次数

% 
% global initial_flag;
% initial_flag = 0;

% initialize Silverback
% Silverback=[];
% Silverback_Score=inf;
Silverback=Gbest.Position;
Silverback_Score=Gbest.Cost;
%Initialize the first random population of Gorilla
% X=initialization(pop_size,variables_no,upper_bound,lower_bound);
X=Position;

if g>max_iter
    It=max_iter;
else
    It=g;
end


 %It=g;

% for i=1:pop_size
% %     Pop_Fit(i)=fobj(X(i,:),funcid);%#ok
%      Pop_Fit(i)=benchmark_func(X(i,:)',funcid);  %原版不需要点
%     if Pop_Fit(i)<Silverback_Score
%             Silverback_Score=Pop_Fit(i);
%             Silverback=X(i,:);
%     end
% end
Pop_Fit=Cost;

GX=X(:,:);
lb=ones(1,variables_no).*lower_bound;
ub=ones(1,variables_no).*upper_bound;

%%  Controlling parameter

p=0.03;
Beta=3;
w=0.8;

%%Main loop


a=(cos(2*rand)+1)*(1-It/max_iter);
C=a*(2*rand-1);

%% Exploration:

for i=1:pop_size
    if rand<p
        GX(i,:) =(ub-lb)*rand+lb;
    else
        if rand>=0.5
            Z = unifrnd(-a,a,1,variables_no);
            H=Z.*X(i,:);
            GX(i,:)=(rand-a)*X(randi([1,pop_size]),:)+C.*H;
        else
            GX(i,:)=X(i,:)-C.*(C*(X(i,:)- GX(randi([1,pop_size]),:))+rand*(X(i,:)-GX(randi([1,pop_size]),:))); %ok ok

        end
    end
end

GX = boundaryCheck(GX, lower_bound, upper_bound);

% Group formation operation
for i=1:pop_size
    %          New_Fit= fobj(GX(i,:),funcid);
    New_Fit=benchmark_func(GX(i,:)',funcid);  %原版不需要点
    if New_Fit<Pop_Fit(i)
        Pop_Fit(i)=New_Fit;
        X(i,:)=GX(i,:);
    end
    if New_Fit<Silverback_Score
        Silverback_Score=New_Fit;
        Silverback=GX(i,:);
    end
end

%% Exploitation:
for i=1:pop_size
    if a>=w
        g=2^C;
        delta= (abs(mean(GX)).^g).^(1/g);
        GX(i,:)=C*delta.*(X(i,:)-Silverback)+X(i,:);
    else

        if rand>=0.5
            h=randn(1,variables_no);
        else
            h=randn(1,1);
        end
        r1=rand;
        GX(i,:)= Silverback-(Silverback*(2*r1-1)-X(i,:)*(2*r1-1)).*(Beta*h);

    end
end

GX = boundaryCheck(GX, lower_bound, upper_bound);

% Group formation operation
for i=1:pop_size
    %          New_Fit= fobj(GX(i,:),funcid);
    New_Fit=benchmark_func(GX(i,:)',funcid);  %原版不需要点
    if New_Fit<Pop_Fit(i)
        Pop_Fit(i)=New_Fit;
        X(i,:)=GX(i,:);
    end
    if New_Fit<Silverback_Score
        Silverback_Score=New_Fit;
        Silverback=GX(i,:);
    end
end

% [~,index]=sort(Pop_Fit);
% X=X(index,:);
% Pop_Fit=Pop_Fit(:,index);
Gbest.Cost=Silverback_Score;
Gbest.Position=Silverback;
end


function [ X ] = boundaryCheck(X, lb, ub)
for i=1:size(X,1)
    FU=X(i,:)>ub;
    FL=X(i,:)<lb;
    X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
end
end
