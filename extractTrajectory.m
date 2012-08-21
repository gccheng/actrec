function [ extractTrajectory ] = extractTrajectory( videofile, desc_file )
%EXTRACTTRAJECTORY Extract trajectories from the video
%   This is a wrap function that uses another c++ program to extract
%   trajectories (Action Recognition by Dense Trajectories)
% videofile
%       the video file including relative or full path like 
%       './person01_handclapping_d1_uncomp.avi'
% desc_file
%       result file for descriptors

command = ['./Actrec ', videofile, ' > ', desc_file];
system(command);

end

