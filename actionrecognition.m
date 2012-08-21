function [matWordAction, before] = actionrecognition(dirTrain, dirTest)

% dirTrain = '/home/cheng/Downloads/KTH';
%[ codebook, features_action, idx, ngroups_video ] = constructCodeBook( dirTrain );
features = importdata('features.mat');
features_action = importdata('features_action.mat');
ngroups_video = importdata('ngroups_video.mat');
features_hoghof = features(3:end, :);
nVocabulary = 10;
[idx, codebook] = kmeans(features_hoghof', nVocabulary, 'distance', 'sqEuclidean');

%[ matWordAction, before ] = trainModel( features_action, idx, ngroups_video );

% dirTest = '/home/Downloads/KTH/testing';
matWordAction = importdata('matWordAction.mat');
before = importdata('before.mat');
[~] = testModel(dirTest, codebook, matWordAction, before);

end