function CombinedAlg=dataInput4Plot(varargin)
CombinedAlg=struct;
% Parse optional parameters
for i = 1:length(varargin)
    CombinedAlg.(strcat('Alg',string(i)))=varargin{i};
end
