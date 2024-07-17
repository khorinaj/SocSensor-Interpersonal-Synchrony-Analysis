function [staout]=staset(V,dim,method)
switch method
    case 1
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim),...
            skewness(V,dim),kurtosis(V,dim)];
    case 2
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim),...
            skewness(V,dim),kurtosis(V,dim),max(V,[],dim),min(V,[],dim)];
    case 3
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim),...
            skewness(V,dim),kurtosis(V,dim),max(V,[],dim),min(V,[],dim),max(V,[],dim)-min(V,[],dim)];
    case 4
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim),...
            skewness(V,dim),kurtosis(V,dim),max(V,[],dim)-min(V,[],dim)];
    case 5
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim),...
            skewness(V,dim),kurtosis(V,dim), prctile(V,25,dim),prctile(V,75,dim)];
    case 6
        staout=[mean(V,dim),std(V,dim),(std(V,dim)./mean(V,dim))*100,median(V,dim)];
end
end