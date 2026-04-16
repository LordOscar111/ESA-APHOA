function [S_Position,S_Cost]=queueSample(queue,num)
% Get num individuals from the queue
    if num>queue.size 
        num=queue.size;
    end

    if  queue.size==queue.capacity
        index=randperm(queue.capacity,num);
    else
        index=randperm(queue.size,num);
        if queue.tail<queue.head
            index=mod(index-1+queue.head, queue.capacity)+1 ;
        end
    end

    if queue.size==0
        S_Position=[];
        S_Cost=[];
    else
        S_Position=queue.Popsition(index,:);
        S_Cost=queue.Cost(index);
    end

end