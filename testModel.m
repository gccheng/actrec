function [labels, precision] = testModel(dirTest, codebook, matWordAction, before)

fprintf('<============== Test Model ==============>\n');

dslist = dir(dirTest);
dssize = size(dslist, 1); %size(dslist, 1);

labels = cell(dssize-2, 1);
precision=zeros(dssize-2, 1);

nVocabulary = 10;
codebook_norm = dot(codebook, codebook, 2);


ind = 0;
for d=1:dssize
    
    totalTest_video = 0;
    totalCorrect_video = 0;
    
    dsTmp = dslist(d).name;
    isValid = dslist(d).isdir;
    if (isValid && (~strcmp('.',dsTmp)) && (~strcmp('..',dsTmp)))
        videolist = get_files([dirTest, '/', dsTmp]);
        
        ind = ind + 1;
        numFiles = size(videolist, 1); %1;%size(videolist, 1);
        labels{ind} = [];
        for fi=1:numFiles
            
            totalTest_video = totalTest_video + 1;
            
           groupTrajectory(videolist{fi});     % generate groups using actrec and ganc
           features_thisvideo = getFeatures(extractShortFilename(videolist{fi}));
           ngroups_thisvideo = size(features_thisvideo,2);
           
           % compute pair-wise distance between each group and each code
           hoghof_thisvideo = features_thisvideo(3:end, :);   % 17-dimensional HOGHOF feature
           hoghof_thisvideo_norm = dot(hoghof_thisvideo, hoghof_thisvideo, 1);
           dist_codebook_thisvideo = bsxfun(@plus, codebook_norm, hoghof_thisvideo_norm)...
               - 2*(codebook*hoghof_thisvideo);
           [~, idx_thisvideo] = min(dist_codebook_thisvideo);
           
           % get BoW representation
           wordFreq = zeros(nVocabulary, 1);
           for wf=1:nVocabulary
               wordFreq(wf) = wordFreq(wf) + sum(idx_thisvideo(:)==wf) + 1;
           end
           wordFreq = wordFreq / (sum(wordFreq(:))+nVocabulary);
           
           % obtain the temporal relationship
           before_thisvideo = zeros(nVocabulary, nVocabulary);
            for j=1:ngroups_thisvideo
                for k=j+1:ngroups_thisvideo
                    j_start = features_thisvideo(1,j);
                    j_end = features_thisvideo(2,j) + 15;
                    k_start = features_thisvideo(1,k);
                    k_end = features_thisvideo(2,k) + 15;

                    if (j_end < k_start)
                        before_thisvideo(idx_thisvideo(j), idx_thisvideo(k)) = ...
                            before_thisvideo(idx_thisvideo(j), idx_thisvideo(k)) + 1;
                    elseif (j_start > k_end)
                        before_thisvideo(idx_thisvideo(k), idx_thisvideo(j)) = ...
                            before_thisvideo(idx_thisvideo(k), idx_thisvideo(j)) + 1;                
                    end
                end
            end
            before_thisvideo = before_thisvideo/ngroups_thisvideo;
           
           % determine the action
           % 1: hoghof part
           dist_thisvideo_actions_hoghof = bsxfun(@plus, dot(wordFreq, wordFreq,1), dot(matWordAction, matWordAction, 1))...
               - 2*(wordFreq'*matWordAction);                       % 1*nAction vector
           dist_thisvideo_actions_hoghof = dist_thisvideo_actions_hoghof / norm(dist_thisvideo_actions_hoghof);
           
           % 2: temporal relationship part
           dist_thisvideo_actions_tr = zeros(1,size(before,3));
           for j=1:size(before,3)
               before_actionj = squeeze(before(:,:,j));
               C = pinv(sqrt(before_actionj))*before_thisvideo*pinv(sqrt(before_actionj));
               [~,~,d1,d2] = eigen_decomposition(C);
               dist_thisvideo_actions_tr(j) = sum(sqrt(log([d1;d2])));
           end
           dist_thisvideo_actions_tr = dist_thisvideo_actions_tr / norm(dist_thisvideo_actions_tr);
           
           % 3: combine and decide
           dist_thisvideo_actions = dist_thisvideo_actions_hoghof.*dist_thisvideo_actions_tr;
           [~, I] = min(dist_thisvideo_actions);
           labels{ind} = [labels{ind}, I(1)];
           if (I(1)==ind)
               totalCorrect_video = totalCorrect_video + 1;
           else
               
           end
           
        end
        precision_action = totalCorrect_video / totalTest_video;
        precision(ind) = precision_action;
        fprintf('%d===>Precision: %f\n\n', ind, precision_action);
    end
    
end

save('precision', 'precision');
save('labels', 'labels');


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