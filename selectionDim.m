function [dim,ub,lb]=selectionDim(funcid)
if funcid > 12 && funcid < 14
    dim = 905; % dimensionality of the objective function.
else
    dim = 1000;
end
if(ismember(funcid, [1,4,7,8,11,12,13,14,15]))
    lb = -100;
    ub = 100;
end
if(ismember(funcid, [2,5,9]))
    lb = -5;
    ub = 5;
end
if(ismember(funcid, [3,6,10]))
    lb = -32;
    ub = 32;
end