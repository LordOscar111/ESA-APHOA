function [value, queue] = dequeue(queue,m)

value=queue.core(queue.head);

for i=1:m
    if queue.size == 0
        error('Queue is empty');
    end
    queue.head = mod(queue.head, queue.capacity) + 1;    % Circularly move the head pointer
    queue.size = queue.size - 1;
end

end