%% Initializing the circular queue
function queue = CircularQueue(capacity,dim) 
    %Record individual information
    queue.Popsition = zeros(capacity,dim); 
    queue.Cost=zeros(1,capacity);
    queue.core=zeros(1,capacity);

    queue.head = 1; % Head pointer of the queue
    queue.tail = 1; % Tail pointer
    queue.size = 0; % Current queue size
    queue.capacity = capacity; % Max queue size
end

