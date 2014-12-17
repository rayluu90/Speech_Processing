function [ misclassified,successClassified,errorRate ] = speakerID( numCodeword )
% this fucntion will build speaker model based on number of code words 
% k-means algorithm will be used to build the model
% return:
% number of speaker got miss classified
% number of speaker successfully classified
% the error rate
    speakers = timit_female();
  
     % partition speaker train files
    partitioned_speakers = partitionspeakers(speakers,'sa|sx');
    
    % count number of speaker
    numSpeakers = length( speakers );
    
    k = numCodeword;
        
    % Preallocate a cell array for each codebook 
    speakersCodeBook = cell( numSpeakers, 1 );
    for speaker = 1 : numSpeakers
        trainedSpeaker = partitioned_speakers( speaker ).train;
        % Concatenate all data together
        trainingData = getTrainingData( trainedSpeaker, timitFolder );
        
        % Do k mean for each speaker
        speakersCodeBook{ speaker } = kmean( trainingData,k );
    end
    
    % Preallocate space for confusion matrix
    confusion = zeros( numSpeakers,numSpeakers );
    misclassified = 0; successClassified = 0; total = 0;

    for speaker = 1 : numSpeakers
        % Test terrance for each speaker
        uterrances = partitioned_speakers( speaker ).test;
        numUterrances = length ( uterrances );
        
        for uterrance = 1 : numUterrances
            testUterrance = uterrances( uterrance );
            % test data vectors
            testVectors = spReadFeatureDataHTK( testUterrance );
            % Preallocate space for scores
            scores = zeros( 1,numSpeakers ); 
            % for each speaker model
            for speakerTh = 1 : numSpeakers
                % codebook for each speaker
                codebook = speakersCodeBook{ speakerTh };
                % compute the distortion of each test column vector against
                % each codebook
                [ minDistortion,~ ] = computeDistortions( testVectors, codebook );
                % average the distortion 
                sumDistortions = sum( minDistortion );    
                % set to each speaker
                scores( speakerTh ) = sumDistortions;
            end
            
            % find the minimum score and return the index of it
            [ ~,classifiedSpeaker_index ] = min(scores);
            
            confusion( speaker,classifiedSpeaker_index ) = confusion( speaker,classifiedSpeaker_index ) + 1;            
            % if the current file belong to the current speaker,
            % successfully classified
            if( speaker == classifiedSpeaker_index )
                successClassified = successClassified + 1;
            else
                misclassified = misclassified + 1;
            end            
        end
        total = total + numUterrances;
    end
    
   % Calculating the error rate
   errorRate = ( misclassified ./ total ) .* 100;
   
   % Display Confusion matrix
   visConfusion(confusion);
   
end

function codebook = kmean( trainingData,k_num )
% Classify the data base on the number of k
% return the number of k represent the codebook

    % Determine the size of training data
    columns = size ( trainingData,2 );

    % pick random columns based on number of k
    initialCodeWords = randperm( columns,k_num );

    % Select k vectors at random as initial centers from training sample X
    newCenter_k = trainingData( :,initialCodeWords );
    % set old distortion to infinity
    old_distortion = inf;
    done = false;
    while( ~done )
        % Compute d(xi,cj) for each training vector and center
        [ closestDist,closestIndex ] = computeDistortions( trainingData,newCenter_k );
        % preallocate the cell array based on number of k
        trainingDataEachPartition = cell( k_num,1 ) ;
        for kth = 1 : k_num
            % Partition training vectors according to cj which produced smallest distortion
            trainingDataEachPartition{ kth } = trainingData( :,closestIndex == kth );
        end

        % sum of all minimum distortioin
        new_distortion = sum( closestDist );

        if ( new_distortion / old_distortion > 0.95 )
            % if new distortion / old distorton > theshold
            done = true;
        else
            % if new distortion / old distorton < theshold
            %  old distortion = new distortion
            old_distortion = new_distortion;

            for kth = 1 : k_num
                % for each k
                % get data from each partition
                data = trainingDataEachPartition { kth };
                % Transpose the data
                transposeData = data';
                numColumn = size( transposeData,2 );
                % Preallocate space
                avgData = zeros( 1,numColumn );

                for column = 1 : numColumn
                    % for each of the transposed column
                    % compute the mean of the data
                    columnData = transposeData( :,column );
                    % set the mean back to original column
                    avgData( column ) = mean( columnData );
                end
                % Transpose the data back and set it as the new center
                newCenter_k( :,kth ) = avgData';
            end
        end
    end
    % set the code = to the center points
    codebook = newCenter_k;
end


function trainingData = getTrainingData ( featuresFilesList)
% This function is to concatenate the training data together in to one big
% feature vectors

    % count number of feature files
    numFeaturesVectors = length( featuresFilesList );
    
    trainingData = [];
    for featureFile = 1 : numFeaturesVectors
        getFeaturesFile = featuresFilesList( featureFile );
        featureVectors = spReadFeatureDataHTK( getFeaturesFile );
        % Concatenate the data togather
        trainingData = [ trainingData,featureVectors ];
    end
end

function [ distance,closestIndex ] = computeDistortions( trainingData,kVectors  )
% [ closestDist,closestDistIndex,index ] = computeDistortions( xi,cj  )
% This function help compute the distortion for the training data against kvectors
% return:
%   a vector with closest distance
%   a vector with closest index 

    % get the size of training data
    numColumns = size( trainingData,2 );

    % Preallocate space for closest distance by on 
    closestIndex = zeros( 1,numColumns );
    distance = zeros( 1,numColumns );
    for column = 1 : numColumns
        % get each column data
        featureVector = trainingData( :,column );
        % compute clossest distance and index
        [ minDist, minIndex ] = mindist( featureVector,kVectors );
        
        closestIndex( column ) = minIndex;
        distance( column ) = minDist;
    end
end

