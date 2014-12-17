function [P, PMixtures] = gmmLikelihood(gmm, RowVectors)
% [P PMixtures] = gmmLikelihod(gmm, RowVectors)
%
% Given a Gaussian mixture model and a set of row-vector feature vectors,
% compute the likelihood of the each row of RowVectors:
% P(idx) contains the likelihood of RowVectors(idx,:) given
% model gmm.
%
% If output PMixtures is present the contribution to each mixture
% to the total likelihood of each observation will also be returned:
% PrMixtures(row-vector ridx, mixture midx) contains the contribution
% of mixture midx to the probability for observation RowVectors(ridx,:).
% Each row of PrMixtures sums to the corresponding entry of Pr.

narginchk(2,2);  % Right number of parameters?

% model and data parameters
N = size(RowVectors,1);	
Mixtures = length(gmm.c);	

P = zeros(N, 1);	% init
if nargout > 1
  % Caller wants likelihod by each mixture, initialize
  PMixtures = zeros(N, Mixtures);
end

% on a mixture by mixture basis, find the likelihood of the row
% vectors in RowVectors and weight by the mixture's prior
for mix=1:Mixtures
  % Compute column vector giving likelihod of each feature vector
  % for mixture mix weighted by the mixture's prior.
  PMix = gmm.c(mix) * f_gauss(RowVectors, gmm.means{mix}, gmm.cov{mix});
  % Add to sum of mixtures
  P = P + PMix;
  if nargout > 1
    % Save mixture by mixture likelihoods if the caller wants them. 
    PMixtures(:,mix) = PMix;
  end
end


