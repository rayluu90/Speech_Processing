function gamma = gmmExpectation(gmm, data)
% gamma = gmmExpectation(gmm, data)
% Given a Gaussian mixture model (gmm) and data matrix (data) where each 
% row is an observation, compute the expected contribution of each mixture
% k to the likelihood of each observation i and return it in gamma(k,i).

% Begin by computing the likelihood of each observation with respect
% to a specific Gaussian, including the weight (prior) probability.
% You will need to use f_gauss and the weights here or gmmLikelihood
% with both outputs (model and mixture likelihoods)

Mixtures = length(gmm.c);  % One prior for each mixture
T = size(data, 1);  % T row vectors of data
gamma = zeros(Mixtures, T);

% Populate the gamma matrix, you can usee gmmLikelihood to 
% compute the probabilities of an observation with respect
% to the model and to the indvidual mixtures.

% complete me...
% Get probablity of each mixture for each row
% the fuction will return a matrix ( T,mixtures_probablity )
P = computeEachMixtureProbability(gmm, data);
% for each column T in ( Mixtures,T )
for t = 1 : T
    % get the column number to get data from ( T,mixtures_probablity )
    % sum up the all of the mixture probablity
    P_total = sum( P( t,: ) );
    % set each gamma( Mixtures,T ) = each
    % ( T,mixtures_probablity ) / mixtures_probablity_total
    gamma( :,t ) = P( t,: ) / P_total;
end

% Sanity check to help ensure your code is correct...
% (Make sure you understand why this works.  Note that
% we should be checking if it is equal to T, but there may
% be small rounding errors.)
assert(sum(sum(gamma)) - T < 1e-5, 'Expectation is not correct.');

    

