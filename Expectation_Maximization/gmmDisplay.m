% gmmDisplay.m
% CS682 Speech Processing
% Written by: Professor Marie Roch
% San Diego State University

function gmmDisplay(gmm)
% gmmDisplay(gmm)
% Write GMM parameters to terminal in human readable format.

if nargin < 2
  DiagonalCov = 0;
end

for mixture=1:length(gmm.c)
    fprintf('mixture %d:  weight %.3f\n', mixture, gmm.c(mixture))
    fprintf('%.3f ', gmm.means{mixture});
    fprintf(' mu\n');
    if sum(sum(gmm.cov{mixture})) - sum(diag(gmm.cov{mixture})) < 1e-6
        fprintf('%.3f ', diag(gmm.cov{mixture}));
        fprintf('diag(cov):  \n')

        fprintf('\n');
    else
        fprintf(' cov\n')
        gmm.cov{mixture}
    end
end
