% Find ground-truth communities of DBLP roughly 100 in size
% compute fmeas, set size of HK, PPR.

% dataset = 'dblp';
% load(dataset,'/scratch/dlgeich/kyle/dblp/dblp');
load /scratch/dgleich/kyle/dblp/dblp;
addpath('/scratch2/dgleich/kyle/kdd/ppr');
addpath('/scratch2/dgleich/kyle/kdd');

n = size(A,1);
C(n,end) = 0;

% find communities of size 80 < size < 400
n = size(A,1);
e = ones(n,1);
commsize = e'*C;
comminds = find(commsize>80);
dummy = find(commsize(comminds)<400);
comminds = comminds(dummy);
disp(length(comminds))

% now comminds contains indices of C corresponding to communities
% with size between 50 and 500.

%% Next, run PPR and HK on all communities found this way.
% Then we find an example that is representative and easily visualized.



totalcommunities = length(comminds);
bestfmeas = zeros(totalcommunities,2);
bestrecsize = zeros(totalcommunities,2);
condofbestfmeas = zeros(totalcommunities,2);
commsizes = zeros(totalcommunities,2);

for numcom=1:totalcommunities
    comm = comminds(numcom);
    verts = find(C(:,comm));
    commsizes(numcom) = numel(verts);
 
    deg = numel(verts);
    recalls = zeros(deg,2); % hk = 1, ppr = 2
    precisions = zeros(deg,2);
    fmeas = zeros(deg,2);
    conds = zeros(deg,2);

    for trial = 1:deg
        [bset,conds(trial,1),cut,vol,~,~] = hkgrow1(A,verts(trial),'t',5);
        recalls(trial,1) = numel(intersect(verts,bset))/numel(verts);
        precisions(trial,1) = numel(intersect(verts,bset))/numel(bset);
        functionID = 1;
        fmeas(trial,functionID) = 2*recalls(trial,functionID)*precisions(trial,functionID)/(recalls(trial,functionID)+precisions(trial,functionID));
        if fmeas(trial,functionID) > bestfmeas(numcom,functionID),
            bestfmeas(numcom,functionID) = fmeas(trial,functionID);
            bestrecsize(numcom,functionID) = numel(bset);
            condofbestfmeas(numcom,functionID) = conds(trial,functionID);
        end
        [bset,conds(trial,2),cut,vol] = pprgrow(A,verts(trial));
        recalls(trial,2) = numel(intersect(verts,bset))/numel(verts);
        precisions(trial,2) = numel(intersect(verts,bset))/numel(bset);
        functionID = 2;
        fmeas(trial,functionID) = 2*recalls(trial,functionID)*precisions(trial,functionID)/(recalls(trial,functionID)+precisions(trial,functionID));
        if fmeas(trial,functionID) > bestfmeas(numcom,functionID),
            bestfmeas(numcom,functionID) = fmeas(trial,functionID);
            bestrecsize(numcom,functionID) = numel(bset);
            condofbestfmeas(numcom,functionID) = conds(trial,functionID);
        end
    end
    fprintf('CommSize = %i \t best hk = %8.4f  setsize=%i cond=%6.4f \t best ppr = %8.4f  setsize =%i cond=%6.4f \n',length(verts),bestfmeas(numcom,1),bestrecsize(numcom,1), condofbestfmeas(numcom,1), bestfmeas(numcom,2), bestrecsize(numcom,2), condofbestfmeas(numcom,2));
end

fprintf('hk: mean fmeas=%6.4f \t mean setsize=%6.4f \t mean cond=%6.4f \t ppr: mean fmeas=%6.4f \t mean setsize=%6.4f \t mean cond=%6.4f \n', ...
		sum(bestfmeas(:,1))/totalcommunities, sum(bestrecsize(:,1))/totalcommunities, sum(condofbestfmeas(:,1))/totalcommunities, ...
		sum(bestfmeas(:,2))/totalcommunities, sum(bestrecsize(:,2))/totalcommunities, sum(condofbestfmeas(:,2))/totalcommunities);

save(['/scratch2/dgleich/kyle/kdd/' 'communityimage' '.mat'],'fmeas','conds','recalls','precisions', 'bestrecsize', 'condofbestfmeas','bestrecsize','comminds','-v7.3');