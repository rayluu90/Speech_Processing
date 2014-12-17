function nextmodel = gmmMaximize(model, gamma, data, diagonal)
% new = gmmMaximize(current, gamma, data, diagonal)
% Given a current GMM, expectation gamma, and row-oriented training data,
% estimate a new GMM.

narginchk(3,4);  % Verify input arguments
if nargin < 4
    diagonal = true;
end

[T, Dim] = size(data);  % Number of observations & dimensions in training data
Mixtures = length(model.c);

% Sum across gamma's observation indices to produce gamma_k 
% for each mixture:  gamma_k(mix) = sum_{i=1}^T gamma(mix,i)
gamma_k = sum(gamma, 2);

% Update weights (priors)
nextmodel.c = gamma_k / T;

% Update the means and variance/covariance matrices for each mixture
for k = 1:Mixtures
    
    % Exploit the similarities between updating the mean and covariance
    % Create a matrix for the numerator to multiply each component
    % of the TrainingData or mean offset by a scalar.
    
    % Pull out mixture of interest and make it a column vector.
    Numerator = gamma(k, :)';
    % Replicate with Tony's trick, see
    % http://www.mathworks.com/support/tech-notes/1100/1109.html
    % We stamp out Dim copies of the Numerator
    Numerator = Numerator(:, ones(Dim, 1));
        
    % Update variance-covariance matrix
    % We find how far each of our observations is from the current mean
    % (repmat will be useful) and then multiply each offset by its
    % transpose to build a scatter matrix where the contribution of
    % each observation's scatter is scaled by the contribution of the
    % current mixture.  
    % Be sure that your offsets are Dim x 1 and 1 x Dim so that
    % you end up with a Dim x Dim matrix when you multipy them.
    %
    % The scatter sum is then normalized by the overall contribution of
    % the mixture (gamma_k).
    MeanOffset = data - repmat(model.means{k}, T, 1);
    varcov = zeros(Dim);
    for idx=1:T
        scatter = MeanOffset(idx,:)' * MeanOffset(idx,:);
        varcov = varcov + gamma(k, idx) * scatter;
    end
    nextmodel.cov{k} = varcov / gamma_k(k);
    
    if diagonal
        % discard off diagonal components of variance/covariance matrix
        nextmodel.cov{k} = diag(diag(nextmodel.cov{k}));
    end
    
    % Update means
    nextmodel.means{k} = ...
        sum(Numerator .* data) / gamma_k(k);
    
end