function [distance,column] = mindist(x, vectors)
    % [d, column] = function mindist(x, vectors)
    % Given a vector x and a set of column vectors, find the
    % minimum distortion between x and each column.
    % Return the minimum distortion d and the column index (column) that 
    % produced it (column)
    [dim, columns] = size(vectors);
    if size(x, 1) ~= dim
        error('x and vectors must have the same number of rows')
    end
    % preallocate (for speed, not mandatory) a distortions vector
    % with one entry for every column
    distortions = zeros(1, columns);
    % find the distortion between x and each column
    for idx = 1:columns
     distortions(idx) = euclid2(x, vectors(:,idx));
    end
    % find the smallest one and the column that produced it
    [ distance,column ] = min(distortions);
end

function d = euclid2(x, y)
    % d = euclid2(x, y)
    % Return a distortion metric d between two vectors x and y. 
    % In this case, the distortion metric is the squared Euclidean
    % distance.
    % Find the difference between the two vectors
    % Note that we do not need a loop
    delta = x - y;
    % Take the dot product between the difference vector and itself
    % which is the same as squaring each difference and summing.
    % Again, no loop needed. Note that we could also have used 
    % dot(delta, delta).
    d = delta' * delta;
end