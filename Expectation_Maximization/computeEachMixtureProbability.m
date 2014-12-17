function P = computeEachMixtureProbability(gmm, data)
% this function will compute the likelihood of gaussian mixture model

    means = gmm.means; 
    mixtureWeights = gmm.c;
    cov = gmm.cov;
    
    % find how many mixture weights
    numMixtureWeights = length( mixtureWeights );
    
    % get the number of row vector
    [ rowNum,Dim ] = size( data );
    
    % Preallocate space for all mixture proabablity
    P = zeros( rowNum,numMixtureWeights );
    % for each of row vector
    for row = 1 : rowNum
        % Get data for each row
        x = data( row,: );
        % compute weights of each mixture
        % This will return P( row,mixture_weights ) = ( 1,mixture_weights )
        P( row,: ) = computeWeights( mixtureWeights, Dim, means, cov, x );
    end
end

function weighted = computeWeights( mixtureWeights, d, means, cov , x )
% This function is to compute the weight of each mixture
    numMixtureWeights = size( mixtureWeights,1 );
    weighted = zeros( 1, numMixtureWeights );
    
    for k = 1 : numMixtureWeights
        % get mu from each mixture
        mu = means{ k };
        % get sigma from each mixture
        sigma = cov{ k };
        % get each mixture weight
        c = mixtureWeights ( k );
        % compute the probablity of unweight mixture
        unweightedProbablity = computeProbability( d, mu, sigma , x );
        % compute the probability of the weighted mixture
        weighted( k ) = c * unweightedProbablity;
    end
end

function result = computeProbability( d, mu, Sigma , x )
% This function will compute the probability of the unweighted mixture
    % x - mu
    xMinMu = x - mu;
    % inverse of sigma
    invSigma = inv( Sigma );
    
    % calculating the unweighted mixture
    result = 1 / ( ( 2*pi ).^(d/2) *  det(Sigma)^(1/2) ) * ...
                            exp( (-1/2) * xMinMu  * invSigma * xMinMu' );
end