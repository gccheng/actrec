function [affinity, num_traj ] = getAffinityMatrix( desc_file )
% GETAFFINITYMATRIX get affinity matrix of the trajectories
%   

disp('Computing distances...');
trajs = importdata(desc_file, '\t');
[num_traj, ~] = size(trajs);
traj_mean = trajs(:,2:3);
%traj_shape = trajs(:,8:37);
traj_frame = trajs(:,1);

% distance of mean spatial coordinates 
v_m = dot(traj_mean, traj_mean, 2);
distance_m = bsxfun(@plus,v_m,v_m');
distance_m = distance_m - 2*(traj_mean*traj_mean');
distance_m = sqrt(distance_m);
clear v_m; clear traj_mean;

% distance between trajectory shapes
distance_s = zeros(num_traj, num_traj);
for k=1:15
    traj_comp = trajs(:,(7+2*k-1):(7+2*k));
    v_s = dot(traj_comp, traj_comp, 2);
    dist_comp = bsxfun(@plus,v_s,v_s');
    dist_comp = dist_comp - 2*(traj_comp*traj_comp');
    dist_comp = sqrt(dist_comp);
    distance_s = distance_s + dist_comp;
end
distance_s = distance_s/15.0;
clear v_s; clear traj_comp; clear dist_comp;
clear trajs;

% temporal distance must be less 
distance_t = bsxfun(@minus, traj_frame', traj_frame);
distance_t = abs(distance_t);
%distance_t = bsxfun(@lt, distance_t, 15);
distance_t(distance_t>=15) = Inf;
distance_t(distance_t<15) = 1;
clear traj_frame;

% integrated distances
dist = distance_m .* distance_s .* distance_t;
clear distance_m; clear distance_s; clear distance_t;

% affinity
affinity = exp(-dist.*dist);
dlmwrite('affinity.txt', affinity, 'delimiter', '\t', 'precision', 4);
clear distance; clear dist;

end

