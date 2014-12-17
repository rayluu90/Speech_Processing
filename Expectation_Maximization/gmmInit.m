function gmm = gmmInit(Mixtures, TrainingData, DiagonalCovar)
% gmm = gmmInit(Mixtures, TrainingData, DiagonalCovar)
% Initialize a Gaussian mixture model with the 
% specified number of Mixtures using row-vector
% training data provided in TrainingData.
% If DiagonalCovar is nonzero, the components of TrainingData(n,:)
% are assumed to be independent and off diagonals are set to 0. 

narginchk(3,3);  % Check number of arguments

% determine number vectors & their dimension
[TrainingCount, Dim] = size(TrainingData);		

% Build codebook with desired # of clusters and remember 
% which training vector is closest to each code word

% Complete me...
% Use Matlab kmeans
[closest,codebook] = kmeans( TrainingData,Mixtures );

% Set up parameters
gmm.c = zeros(Mixtures, 1);
gmm.means = cell(Mixtures, 1);
gmm.cov = cell(Mixtures, 1);

gmm.DiagonalCov = DiagonalCovar;      % full/diagonal covariance flag

for mixture = 1:Mixtures  
   % Initialize each mixture
   % complete me...
   avg = zeros( 1,Dim );
   weight = 0;
   covariance = zeros(Dim,Dim);
   
  % Locate all training vectors associated with the mixture'th
  % codeword.
  partitionData = TrainingData( closest == mixture, : );
  
  vectorSize = size( partitionData,1 );
  
  % Calculate the weight of the each mixture
  weight = vectorSize / TrainingCount;
  
  % Take the mean of partitioned data
  avg = mean( partitionData );
  
  % Find the covariance of the data
  covariance = cov( partitionData );
  
  % proportion of training vectors associated with this codeword
  gmm.c(mixture) = weight; % complete me...
  
  % sample mean, variance/covariance of the partition
  
  gmm.means{ mixture } = avg; % complete me...
  
  gmm.cov{mixture} = covariance ; % comlete me...
  
  if gmm.DiagonalCov;
    % diagonalize the variance-covariance matrix
    gmm.cov{mixture} = diag(diag(gmm.cov{mixture}));
  end
  
end





