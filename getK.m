function [ K ] = getK( affinityM )
%GETK compute number of clusters used in graph-cut using the affinity
%matrix.
%   affinityM:
%       affinity matrix

d = eig(affinityM);
d = sort(d, 'descend');

no = length(d);
c = 0.0001;

d2 = d.*d;
d2cumsum = cumsum(d2, 1);
d2 = [d2(2:end,:); Inf];
ci = (1:no)'*c;

exprst = d2./d2cumsum+ci;

[~,K] = min(exprst);
 
end

