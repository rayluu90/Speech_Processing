cd 'peterson-barney'

pb;

cd ..

load('psdata_gmm.mat');

gmm = gmmInit(5,features,true);

figure;

plotGMM(gmm, features);

gmmCreate(5, features);

startFreq = 20;
stopFreq = 10000;

Hz_to_Mel( startFreq,stopFreq );


clear;