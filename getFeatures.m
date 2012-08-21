function [features] = getFeatures(strFile)
% GETFEATURES: extract features from clustering results for the video
% specified by the parameter strFile
% strFile
%       The filename of the video. all the results shared the same name but
%       different extension
%       .avi          The video
%       .groups       Ganc generated 0-seperated groups
%       .cellgroups   Groups in cell matrix (groups in loaded struct)
%       .desc         Actrec generated descriptors (all)
%       .raw          Actrec generated raw trajectories (mean+shape)
% label
%       the class label for the action in the video. 0-indexed

% retrieve groups
groups = importdata([strFile, '.cellgroups']);
[~, nGroups] = size(groups);
features = zeros(2+8+9, nGroups);

% retrieve descriptors
descs = importdata([strFile, '.desc'], '\t');

for k=1:nGroups
   grp_k = groups{k};
   if numel(grp_k)==0
      continue; 
   end
   start_frame = grp_k(1);
   end_frame = grp_k(2);
   grp_k = grp_k(3:end);
   
   hog_k = zeros(8,1);
   hof_k = zeros(9,1);
   
   nTrajs = size(grp_k, 2);
   for i=1:nTrajs
       hog_i = zeros(8,1);
       hof_i = zeros(9,1);
       
       for j=0:11
          hog_i = hog_i + descs(grp_k(i), (37+8*j+1):(37+8*j+8))';
          hof_i = hof_i + descs(grp_k(i), (133+9*j+1):(133+9*j+9))';
       end
       hog_i = hog_i./12;
       hof_i = hof_i./12;
       
       hog_k = hog_k + hog_i;
       hof_k = hof_k + hof_i;
   end  
   
   hog_k = hog_k/sum(hog_k(:));
   hof_k = hof_k/sum(hof_k(:));
   
   features(:,k) = [start_frame; end_frame; hog_k; hof_k];
   
end

end

