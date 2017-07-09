function [label eng pcost] = get_labels(graph, datacost, datacost_scale, smoothcost)
% Input
% graph [NxN]     : represents a sparse adjacency matrix
% datacost [NxL]  : contains cost of N points w.r.t L labels
% datacost_scale  : scale of data cost
% smoothcost      : smoothness cost of the MRF model 

% Output
% label           : the output labels
% eng             : the energy of the system with the esimated labels
% pcost           : cost of each point w.r.t its assigned label.


% Make squared residual
datacost = datacost.^2;

% Label initalisation
[ n  num_hyp ] = size(datacost);
[dum ilabel] = min(datacost,[],2);

% Create Graph cut object
h = GCO_Create(n,num_hyp);

% Uniform cost is used for all label pairs
GCO_SetSmoothCost(h,int32(smoothcost*(~eye(num_hyp))));

% Set neighbors
GCO_SetNeighbors(h,graph);

% Set data cost
GCO_SetDataCost(h,int32(min(datacost_scale,(datacost'*datacost_scale))));
%GCO_SetLabelCost(h,int32(0)); 
% Set labels
GCO_SetLabeling(h,ilabel)


% run alpha-expansion
GCO_Expansion(h);                

% Computer energy
[E D S L] = GCO_ComputeEnergy(h);

% Output engery
eng = E;

% get labelling results
label = GCO_GetLabeling(h);

% Get cost for each datum w.r.t to their label
Tdcost = datacost'; % Transpose dcost matrix
ind = dummyvar(double(label))';
pcost = Tdcost(logical(ind)); % cost of data points w.r.t their labels

% Delete Graph Cut object
GCO_Delete(h);

end
