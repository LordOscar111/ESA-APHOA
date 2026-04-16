function queue = enqueue(queue, Position,Cost,m,y)
  
for i=1:m
    % if queue.size == queue.capacity
    %     error('Queue is full');
    % end
    queue.Popsition(queue.tail,:) = Position(i,:);    % initializing the array
    queue.Cost(queue.tail)=Cost(i);
    queue.core(queue.tail)=y;
   % queue.data(queue.tail) = value;
    queue.tail = mod(queue.tail, queue.capacity) + 1; % Circularly move the tail pointer
    queue.size = queue.size + 1;
end
end