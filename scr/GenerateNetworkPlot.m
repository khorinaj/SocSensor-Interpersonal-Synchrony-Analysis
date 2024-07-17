function GenerateNetworkPlot(tmat,person,TitleName,varargin)
% plot range is set from session start to end
% Excludeperc5Flag=true;
for i = 1:numel(varargin)
    if ischar(varargin{i}) && strcmpi(varargin{i}, 'Excludeperc')
        % Look for 'method' in varargin and set the method variable
        if i < numel(varargin)
            Excludeperc = varargin{i + 1};
            break
        end

    end
end
% Generate plots
% person = unique([p1,p2]);

% remove S4
%person = setdiff(person,'S4')

%person = {'S4','S3','S6','S7','S5','S1','S2','T1','R1','R2'}

categ = zeros(size(person));
categ(startsWith(person,'S'))=1;
categ(startsWith(person,'M'))=2;
categ(startsWith(person,'E'))=3;
categ(startsWith(person,'T'))=4;
categ(startsWith(person,'R'))=5;

% for i=1:length(person)
%     for j=1:length(person)
%         r1 = endsWith(p1,person(i));
%         r2 = endsWith(p2,person(j));
%         tmp = find(r1&r2);
%         if(~isempty(tmp))
%             idx(i,j) = tmp;
%         else
%             r1 = endsWith(p2,person(i));
%             r2 = endsWith(p1,person(j));
%             tmp = find(r1&r2);
%             if(~isempty(tmp))
%                 idx(i,j) = tmp;
%             else
%                 idx(i,j) = 0;
%             end
%
%         end
%     end
% end

% for i=1:length(person)
%     for j=1:length(person)
%
%         if(idx(i,j)>0)
%             tmat(i,j) = PerTimeOverThres(idx(i,j));
%         else
%             tmat(i,j) = 0;
%         end
%     end
% end

cm = [linspace(1,0,64)',linspace(1,0.2,64)',ones(64,1)];

figure, clf
% set(gca,'Position',[50,50,1100,600])
% subplot(1,3,1);

imagesc(tmat);
xticks(1:length(person));
xticklabels(cellstr(person));
yticks(1:length(person));
yticklabels(cellstr(person));
colorbar
colormap(cm)
title(TitleName,'Interpreter','none')
set(gca,'FontSize',20)
%%% now plot connection pattern

theta = linspace(-pi,pi,length(person)+1)';
pcentre = [cos(theta),sin(theta)];

% subplot(1,3,2)
figure
for i=1:length(person)
    for j=1:length(person)
        ww = 30*tmat(i,j)+0.001;
        wmax = max(tmat(:))*30+0.001;
        if( length(person)>10 )
            ww = ww/2;
            wmax = wmax/2;
        end
        h=plot(pcentre([i,j],1),pcentre([i,j],2));
        h.Color=1-([1,0.5,0]*(ww/wmax));
        h.LineWidth=3*ww;
        hold on
    end
end

theta2 = linspace(-pi,pi,30)';
pmark = [cos(theta2),sin(theta2)]*0.1;

pcols = [0.8,0,0;  % kids
    0.6,0.2,0;  % kids
    0.4,0.6,0.01;  % kids
    0,0.8,0;  % teachers
    0.5,0.5,0.5];  % researchers

for i=1:length(person)
    patch(pmark(:,1)+pcentre(i,1), pmark(:,2)+pcentre(i,2), pcols(categ(i),:) )
    text(pcentre(i,1),pcentre(i,2),person(i),'Color',[1,1,1],'FontWeight','bold','HorizontalAlignment','Center','FontSize',20)
end
axis tight
axis off

% subplot(1,3,3)
figure

    tmat(tmat<Excludeperc) = 0;

G = graph(tmat,person)

h=plot(G)
set(h,"LineWidth",2,"NodeFontSize",20,"MarkerSize",8)
axis equal
axis off

