%% experiment code

% meets = importdata('meets.mat');
% nActions = size(meets,3);
% 
% for i=1:nActions
%    meets1 = meets(:,:,i);
%    meets2 = (meets1-min(meets1(:)))/(max(meets1(:))-min(meets1(:)))*100;
%    meets3 = int8(meets2);
%    figure;
%    bar3c(meets3);
% end


before = importdata('before.mat');
nActions = size(before,3);

for i=1:nActions
   before1 = before(:,:,i);
   before2 = (before1-min(before1(:)))/(max(before1(:))-min(before1(:)))*100;
   before3 = int8(before2);
   figure;
   bar3c(before3);
end