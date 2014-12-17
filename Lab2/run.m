load('anc.mat');

% row = size(r,1);


% r = r(1:40,:);

r;

r_ = r(:,1);
Nr = r(:,2);

% format shortG

rstar_sgts = sgtsmooth( r_ , Nr );


% title( 'c vs. cstar' );
% xlabel 'c';
% ylabel 'Zc';

clear;