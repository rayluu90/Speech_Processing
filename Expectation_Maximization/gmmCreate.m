function gmm = gmmCreate(Mixtures, TrainingData, DiagonalCovar)
% gmm = gmmCreate(Mixtures, TrainingData, DiagonalCovar)
% Create a Gaussian mixture model from training data.
%
% Inputs:
%       Mixtures - number of mixtures
%       TrainingData - N x D matrix where each of the N rows is a 
%               feature vector of dimension D
%       DiagonalCovar - Optional true|false (default true)
%               If true, assumes that components of
%               training vectors are independent and off diagonal
%               covariance elements will be set to zero.
%               Note that it is very common to do this with
%               cepstral feature vectors as they can be shown
%               to be asymptotically independent with respect
%               to a wide class of signals (nearly anything that
%               you would be likely to observe).  In addition, 
%               matrix multiplication is greatly sped up by diagonal
%               matrices ( O(D) vs O(D^2) ).
%           
% Output:  gmm - structure containing the following fields:
%   c - vector of mixture weights
%   means - cell array of mixture means
%   cov - cell array of variance-covariance matrices
%
% See also: gmmDisplay() for an example of accessing the fields

% Make sure # of input arguments falls between the low and high value
error(nargchk(2,3,nargin));

if nargin < 3
  DiagonalCovar = true;
end


EMMaxIterations = 5;	% maximum number of iterations of EM algorithm
Verbose = 1;		% show progress = 1, quiet = 0


% Seed the model
gmm = gmmInit(Mixtures, TrainingData, DiagonalCovar);

% determine number vectors & their dimension
[TrainingCount, Dim] = size(TrainingData);
if Dim > TrainingCount
    warning('Problem:  %d observations of dimension %d, transposed?', ...
        TrainingCount, Dim);
end

EMCount = 1;	% first iteration
Stop = false;	% termination condition

% Gamma_Mix_X_Train(k, i) Contribution of mixture k given 
% TrainingVector(i, :) to the overall probability of the
% training vector.  (Denoted by gamma_k^i in Huang et al.)
Gamma_Mix_X_Train = zeros(Mixtures, TrainingCount);

logP = sum(log(gmmLikelihood(gmm, TrainingData)));

if Verbose
  fprintf('log P of seed (initial) model = %f\n', logP);
end

% Use EM algorithm to improve
while ~ Stop
    
    Pprevious = logP;  % save likelihood of current model
    
    % Expectation
    % Create matrix of gamma(k,i) where k is the mixture
    % index and i is the observation index.  gamma(k,i)
    % is the expected value of the contribution of mixture k
    % to the probability of observation i given our current model.
    gamma = gmmExpectation(gmm, TrainingData);
    
    % Maximization ---------------
    % Use a maximum likelihood estimator to update the model
    gmm = gmmMaximize(gmm, gamma, TrainingData);
        
    % determine likelihood with new model
    % If we were writing production code, we would cache the probability
    % compuations and pass them to gmmExpectation so that we do not
    % compute the likelihoods twice for the same model.  For pedagogical
    % reasons, we do not do that here.
    P = gmmLikelihood(gmm, TrainingData);  % likelihood of each vector
    logP = sum(log(P));  % product of likelihoods in log space to prevent underflow
    
    if Verbose	% display progress if so requested
        fprintf(['log P iteration %d = %f ', ...
            '(%g improved from previous iteration) -----------\n'], ...
            EMCount, logP, logP - Pprevious);
        %gmmDisplay(gmm);
    end
    
    EMCount = EMCount + 1;        % another iteration done...
    
    % Check if we have converged or met the maximum
    % number of iterations
    if logP <= Pprevious || EMCount > EMMaxIterations
        Stop = true;
    end
end

1;


