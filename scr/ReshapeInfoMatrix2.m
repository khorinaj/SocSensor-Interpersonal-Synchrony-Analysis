function [TimePrepare,InfoPrepare]=ReshapeInfoMatrix2(data,SessionsLabelUsed,PairsLabelUsed,MethodExtract)
nrow=size(data,1);
ncol=size(data,2);
% MethodExtract=[repmat("xwHighf",6,1);repmat("wcohHighf",6,1);repmat("wcohLowf",6,1)];
for i= 1:nrow
    if i==1
        TimePrepare=data(i,:)';
        InfoPrepare=[repmat(SessionsLabelUsed(i),ncol,1),...
            repmat(PairsLabelUsed(i),ncol,1),...
            MethodExtract];

    else
        TimePrepare=[TimePrepare;data(i,:)'];
        InfoPrepare=[InfoPrepare;[repmat(SessionsLabelUsed(i),ncol,1),...
            repmat(PairsLabelUsed(i),ncol,1),...
            MethodExtract]];
    end

end

end