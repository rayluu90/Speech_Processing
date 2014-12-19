% plotGMM.m
% CS682 Speech Processing
% Written by: Professor Marie Roch
% San Diego State University

function plotGMM(model, features)

% Find bounding box around data
low = min(features);
high = max(features);

SamplesN = 100;
% Build a 2 component grid spaced over the data with SamplesN^2 grid
% points
[c1, c2] = meshgrid(...
    linspace(low(1), high(1), SamplesN), ...
    linspace(low(2), high(2), SamplesN));

% Build a set of row vectors to evalaute
vectors = [c1(:), c2(:)];
% Find probability at each point
P = gmmLikelihood(model, vectors);
P = reshape(P, size(c1));
surfc(c1, c2, P)
xlabel('c_1')
ylabel('c_2')
zlabel('P(x|model)')
