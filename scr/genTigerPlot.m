function genTigerPlot(bintAll,titleName,varargin)
% nosubplots=length(com)+4;
% Check for EventsTime to include event timing information
% Check for AddingUpFlag to determine if interactions for multiple pairs should be added up
AddingUpFlag = false;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'AddingUpFlag')
        if i < numel(varargin)
            AddingUpFlag = varargin{i + 1};
            break
        end
    end
end

EventsCodeFlag=false;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'EventsTime')
        if i < numel(varargin)
            EventsTime = varargin{i + 1}; 
            EventsCodeFlag=true;
            break
        end
    end
end

EventsCodeEdge = 2.5;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'EventsCodeEdge')
        if i < numel(varargin)
            EventsCodeEdge = varargin{i + 1};
            break
        end
    end
end

fontsize=20;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'FontSize')
        if i < numel(varargin)
            fontsize = varargin{i + 1};
            break
        end
    end
end

if AddingUpFlag
    if EventsCodeFlag
        nosubplots=size(bintAll,1)+6;
    else
        nosubplots=size(bintAll,1)+4;
    end
   
else
    if EventsCodeFlag
        nosubplots=size(bintAll,1)+2;
    else
        nosubplots=size(bintAll,1);
    end

end

    figure
    if EventsCodeFlag
        subplot(nosubplots, 1, [1,2]) ;
        % EventsTime=[0,EventsTime,EventsTime(end)+200];
        EventsTime=[0,EventsTime,size(bintAll,2)*0.04+200];
        % EventsTime=EventsTime-min(EventsTime);
        lineNames={'Events' };
        st=sort((EventsTime(1:(end-1))))+EventsCodeEdge;
        % st(st<0)=0;

        % st=0
        % st=st-st(1);
        % st(2:end)=st(2:end)+5;
        et=sort((EventsTime(2:end)))-EventsCodeEdge;
        % et=et-et(1);
        % et(1:(end-1))=et(1:(end-1))-5;


        startTimes={st};
        endTimes={et};
        timeline(lineNames,startTimes,endTimes)
        xlim([0 size(bintAll,2)*0.04])
        xticks([]);
        yticks([]);

        NextPlotStartIdx=3;
    else
        NextPlotStartIdx=1;
    end

    for i=1:size(bintAll,1)

        subplot(nosubplots, 1, NextPlotStartIdx)

        imagesc(bintAll(i,:))
        if NextPlotStartIdx~=nosubplots
            % remove xticks and yticks labels
            xticks([]);
            yticks([]);
            % remove tick marks and box around plot
            box off;

        else
            yticks([]);
            %        cxticks= xticks*0.04;
            xticks(0:7500:length(bint));
            xticklabels(xticks*0.04/60);
            xlabel('Time/mins')
            %     % remove tick marks and box around plot
            %     box off;
        end
        set(gca, 'FontSize', fontsize);

        title(titleName(i))
        % Get the handle of the title object
        titleHandle = get(gca, 'Title');
        %
        % Set the title position to the right side and middle
        set(titleHandle, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');

        % Get the position of the axes in normalized units
        axesPos = get(gca, 'Position');

        % Adjust the title position
        titlePos = get(titleHandle, 'Position');
        titlePos(1) = 1.5;  % Set the x-coordinate to the right side
        titlePos(2) = 1;  % Set the y-coordinate to the vertical middle
        set(titleHandle, 'Position', titlePos);
        set(gca,'FontSize',fontsize)

        NextPlotStartIdx = NextPlotStartIdx + 1;

    end


    if AddingUpFlag
        subplot(nosubplots, 1, [NextPlotStartIdx,NextPlotStartIdx+3]) ;
        plot(0:(size(bintAll,2)-1),sum(bintAll,1),'Linewidth',1.5)
        xticks(0:7500:size(bintAll,2));
        xticklabels(xticks*0.04/60);
        % xticklabels({'0','5', '10','15', '20','25', '30'});
        set(gca,'FontSize',fontsize)
        xlabel('Time/mins')
        ylabel([{'Total'},{'Intercations'}])
        ylim([-1,max(sum(bintAll,1))+1])
        xlim([0,size(bintAll,2)])
        box off
    end
    % Pairs=[p1,p2];
    % varargout{1} = PerTimeOverThres;
    % varargout{2} = pairs;
end
