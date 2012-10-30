function [ matWordAction, before ] = trainModel( features_action, idx, ngroups_videos )
%train 

fprintf('<==============Train Model ===============>\n');

nVocabulary = 10;

nActions = size(features_action,1);
matWordAction = zeros(nVocabulary, nActions);

% p(word|action)
grp_ind = 1;
for ind=1:nActions
        featuretime_action = features_action{ind};
        nGroups_action = size(featuretime_action, 2);
        index_action = idx(grp_ind:(grp_ind+nGroups_action-1));
        
        wordFreq = zeros(nVocabulary, 1);
        for wf=1:nVocabulary
           wordFreq(wf) = wordFreq(wf) + sum(index_action(:)==wf) + 1;
        end
        
        matWordAction(:,ind) = wordFreq / (sum(wordFreq(:))+nVocabulary);
        
        grp_ind = grp_ind + nGroups_action;
end

% temporal representation -- before(j,k,a): probability of j is before k within action a
before = zeros(nVocabulary, nVocabulary, nActions);
meets = zeros(nVocabulary, nVocabulary, nActions);
% overlaps = zeros(nVocabulary, nVocabulary, nActions);
% starts = zeros(nVocabulary, nVocabulary, nActions);
% during = zeros(nVocabulary, nVocabulary, nActions);
% finishes = zeros(nVocabulary, nVocabulary, nActions);
% equals = zeros(nVocabulary, nVocabulary, nActions);

grp_ind = 1;
for ind=1:nActions
    featuretime_action = features_action{ind};       % feature from one action videos
    nGroups_action = size(featuretime_action, 2);    % # of groups for all videos within this action
    nVideo = size(ngroups_videos, 2);                % # of videos in this actions
    index_action = idx(grp_ind:(grp_ind+nGroups_action-1)); % labels of each group in this action type.
    
    ngroups_videos_this_action = ngroups_videos{ind};  % # of clustered groups in each video in this action
    acc_ngroups_videos_this_action = cumsum(ngroups_videos_this_action);
    acc_ngroups_videos_this_action = [0, acc_ngroups_videos_this_action];
    
    % relations (before, meets, ...equals) between groups.
    for v=1:nVideo
        for j=acc_ngroups_videos_this_action(v)+1:acc_ngroups_videos_this_action(v+1)
            for k=j+1:acc_ngroups_videos_this_action(v+1)
                j_start = featuretime_action(1,j);
                %j_end = featuretime_action(2,j) + 15;
                j_end = featuretime_action(2,j);
                k_start = featuretime_action(1,k);
                %k_end = featuretime_action(2,k) + 15;
                k_end = featuretime_action(2,k);

                % before
                if (j_end < k_start)
                    before(index_action(j), index_action(k), ind) = ...
                        before(index_action(j), index_action(k), ind) + 1;
                elseif (j_start > k_end)
                    before(index_action(k), index_action(j), ind) = ...
                        before(index_action(k), index_action(j), ind) + 1;                
                end
                % meets
                if (j_end == k_start)
                    meets(index_action(j), index_action(k), ind) = ...
                        meets(index_action(j), index_action(k), ind) + 1;
                elseif (j_start == k_end)
                    meets(index_action(k), index_action(j), ind) = ...
                        meets(index_action(k), index_action(j), ind) + 1;                
                end
                % 
            end
        end
    end
        
    
    % normalize the temporal relationships
    before(:,:,ind) = before(:,:,ind)/nGroups_action;
    meets(:,:,ind) = meets(:,:,ind)/nGroups_action;
    
    grp_ind = grp_ind + nGroups_action;
end

save('matWordAction', 'matWordAction');
save('before', 'before');
save('meets', 'meets');

end