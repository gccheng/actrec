function [ codebook, features_action, idx, ngroups_video ] = constructCodeBook( dirTrain )
% CONSTRUCTCODEBOOK Construct codebook for the training dataset.
% dirTrain
%       The directory where the training dataset is

fprintf('<============== Construct Codebook ==============>\n');

nVocabulary = 10;

dslist = dir(dirTrain);
dssize = size(dslist, 1); %size(dslist, 1);

features = [];
features_action = cell(dssize-2,1);  % organize different types of videos into different cells
ngroups_video = cell(dssize-2, 1);   % number of groups in each action(cell) video(matrix)

ind = 0;
for d=1:dssize   %For testing purpose, we only run for two directories+. ..
    dsTmp = dslist(d).name;
    isValid = dslist(d).isdir;
    if (isValid && (~strcmp('.',dsTmp)) && (~strcmp('..',dsTmp)))
        videolist = get_files([dirTrain, '/', dsTmp]);
        
        ind = ind + 1;
        numFiles = size(videolist, 1); %size(videolist, 1);
        features_action{ind} = [];
        for fi=1:numFiles
           fprintf('%d:%d ==============================>\n', ind, fi);
           groupTrajectory(videolist{fi});
           feature_this_video = getFeatures(extractShortFilename(videolist{fi}));
           features = [features, feature_this_video];
           features_action{ind} = [features_action{ind}, feature_this_video];
           ngroups_video{ind} = [ngroups_video{ind}, size(feature_this_video,2)];
        end
    end
end

save('features', 'features');
save('features_action', 'features_action');
save('ngroups_video', 'ngroups_video');
features_hoghof = features(3:end, :);

[idx, codebook] = kmeans(features_hoghof', nVocabulary, 'distance', 'sqEuclidean');
save('codebook', 'codebook');

% Get all the videos under a directory
function [videolist] = get_files(videodir)
    listing = dir(videodir);
    count = size(listing, 1);

    videolist = cell(0);

    % get all valid file names
    for i=1:count
        name = listing(i).name;
        isdir = listing(i).isdir;
        if ((~isdir) && (name(1)~='.'))
            videolist = [videolist; [videodir, '/', name]];
        elseif (isdir && (~strcmp('.',name)) && (~strcmp('..',name)))
            sub_files = files_in_folder([videodir '/', name]);
            videolist = [videolist; sub_files];
        end;
    end;
end

function [files] = files_in_folder(folder)
    files = cell(0);
    listing = dir(folder);
    count = size(listing, 1);
    for i=1:count
        name = listing(i).name;
        isdir = listing(i).isdir;
        if ((~isdir) && (name(1)~='.'))
            files = [files; [folder '/', name]];
        end;
    end;
end

end