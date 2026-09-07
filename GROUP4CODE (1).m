%% GROUP 4: MATLAB PLOTS
clear; 
close all; 
clc;

excelFile = 'C:\Users\DELL\Desktop\GROUP 4.xlsx';
outputFolder = fullfile(fileparts(mfilename('fullpath')), 'GROUP4_numbered_plots');
if ~isfile(excelFile), error('Workbook not found: %s', excelFile); end
if ~isfolder(outputFolder), mkdir(outputFolder); end

% Headers in the workbook start at row 2.
T = readtable(excelFile, 'Range','A2', 'VariableNamingRule','preserve');
age = double(T.("AGE"));
siblings = double(T.("NUMBER OF SIBLINGS"));
tribe = string(T.("TRIBE")); 
hostel = string(T.("HOSTEL/HALL"));
gender = string(T.("GENDER")); 
n = height(T); obs = (1:n)';
[tribeNames,~,tribeID] = unique(tribe,'stable'); 
tribeCount = accumarray(tribeID,1);
[hostelNames,~,hostelID] = unique(hostel,'stable'); 
hostelCount = accumarray(hostelID,1);
[genderNames,~,genderID] = unique(gender,'stable'); 
genderCount = accumarray(genderID,1);
[ageSorted,order] = sort(age);
sibSorted = siblings(order);

%% Line plot
f=figure('Color','w'); 
plot(obs,age,'-o','LineWidth',1.4); 
grid on;
xlabel('Student observation'); 
ylabel('Age (years)'); 
title('Age by student');
savePlot(f,outputFolder,'line_plot');

%% Scatter plot
f=figure('Color','w'); 
gscatter(age,siblings,gender); 
grid on;
xlabel('Age (years)'); 
ylabel('Number of siblings'); 
title('Age versus siblings');
savePlot(f,outputFolder,'scatter_plot');

%% graph
f=figure('Color','w'); 
bar(categorical(tribeNames),tribeCount); 
grid on; xtickangle(35);
xlabel('Tribe'); 
ylabel('Students'); 
title('Students by tribe');
savePlot(f,outputFolder,'bar_graph');

%% Horizontal bar graph
f=figure('Color','w'); 
barh(categorical(hostelNames),hostelCount);
grid on;
xlabel('Students');
ylabel('Hostel/Hall'); 
title('Students by hostel/hall');
savePlot(f,outputFolder,'horizontal_bar_graph');

%% Sankey diagram (tribe to hostel/hall)
pairText=tribe+"|"+hostel; 
[pairNames,~,pairID]=unique(pairText,'stable');
linkWeight=accumarray(pairID,1);
linkTribe=extractBefore(pairNames,"|"); 
linkHostel=extractAfter(pairNames,"|");
f=figure('Color','w'); 
drawSankeyDiagram(linkTribe,linkHostel,linkWeight);
title('Student flow: tribe to hostel/hall'); 
savePlot(f,outputFolder,'sankey_diagram');

%% Stem plot
f=figure('Color','w'); 
stem(obs,siblings,'filled');
grid on;
xlabel('Student observation');
ylabel('Number of siblings');
title('Stem plot of siblings');
savePlot(f,outputFolder,'stem_plot');

%% Step plot
f=figure('Color','w');
stairs(obs,age,'LineWidth',1.5);
grid on;
xlabel('Student observation');
ylabel('Age (years)');
title('Step plot of age');
savePlot(f,outputFolder,'step_plot');

%% Error-bar plot
f=figure('Color','w');
errorbar(obs,age,repmat(std(age,'omitnan')/sqrt(n),n,1),'o-','LineWidth',1.1);
grid on;
xlabel('Student observation'); 
ylabel('Age (years)'); 
title('Age with one standard error');
savePlot(f,outputFolder,'errorbar_plot');

%% Area plot
f=figure('Color','w');
area(obs,[age siblings]); 
grid on;
xlabel('Student observation');
ylabel('Value'); 
title('Area plot: age and siblings');
legend('Age','Siblings','Location','best');
savePlot(f,outputFolder,'area_plot');

%%  Histogram
f=figure('Color','w'); 
histogram(age,'BinMethod','integers');
grid on;
xlabel('Age (years)'); 
ylabel('Students');
title(' Age distribution');
savePlot(f,outputFolder,'histogram');

%% Pareto chart
f=figure('Color','w'); 
pareto(tribeCount,cellstr(tribeNames)); grid on;
title('Pareto chart of tribes'); 
savePlot(f,outputFolder,'pareto_chart');

%% Box plot
f=figure('Color','w'); 
boxplot(age,gender);
grid on;
xlabel('Gender');
ylabel('Age (years)');
title(' Age by gender');
savePlot(f,outputFolder,'box_plot');

%% Pie chart
f=figure('Color','w');
pie(genderCount);
legend(genderNames,'Location','bestoutside');
title('Gender composition'); 
savePlot(f,outputFolder,'pie_chart');

%% Pie chart with percent labels
f=figure('Color','w');
labels=genderNames+" ("+string(round(100*genderCount/sum(genderCount),1))+"%)";
pie(genderCount,labels);
title('Gender composition with percentages');
savePlot(f,outputFolder,'Pie_percent_labels');

%% Logarithmic plots (semilogx, semilogy, and loglog)
f=figure('Color','w');
tl=tiledlayout(1,3,'Padding','compact');
nexttile; 
semilogx(obs,ageSorted,'-o');
grid on; 
title('semilogx'); 
xlabel('Observation');
ylabel('Age');
nexttile; 
semilogy(obs,max(sibSorted,1),'-o');
grid on; 
title('semilogy');
xlabel('Observation');
ylabel('Siblings');
nexttile;
loglog(obs,max(ageSorted,1),'-o');
grid on; 
title('loglog');
xlabel('Observation');
ylabel('Age');
title(tl,' Logarithmic plots');
savePlot(f,outputFolder,'logarithmic_plots');

fprintf('Finished. Saved PNG files to:\n%s\n',outputFolder);

function savePlot(f,folder,name)
exportgraphics(f,fullfile(folder,name+".png"),'Resolution',300);
close(f);
end

function drawSankeyDiagram(source,target,weight)
% Core-MATLAB Sankey drawing (works without an optional sankey function).
[src,~,srcID]=unique(source,'stable');
[dst,~,dstID]=unique(target,'stable');
usable=1-0.018*(max(numel(src),numel(dst))-1);
srcBox=sankeyBoxes(accumarray(srcID,weight),usable);
dstBox=sankeyBoxes(accumarray(dstID,weight),usable);
srcCursor=srcBox(:,1);
dstCursor=dstBox(:,1);
colors=lines(numel(src));
hold on;
for i=1:numel(weight)
    h=weight(i)/sum(weight)*usable; s=srcID(i); 
    d=dstID(i);
    y1=srcCursor(s); 
    y2=dstCursor(d);
    patch([.10 .90 .90 .10],[y1 y2 y2+h y1+h],colors(s,:),'FaceAlpha',.36,'EdgeColor','none');
    srcCursor(s)=y1+h; 
    dstCursor(d)=y2+h;
end
for i=1:numel(src)
    rectangle('Position',[.04 srcBox(i,1) .06 srcBox(i,2)],'FaceColor',colors(i,:),'EdgeColor','w');
    text(.035,srcBox(i,1)+srcBox(i,2)/2,src(i),'HorizontalAlignment','right','FontSize',8);
end
for i=1:numel(dst)
    rectangle('Position',[.90 dstBox(i,1) .06 dstBox(i,2)],'FaceColor',[.25 .25 .25],'EdgeColor','w');
    text(.965,dstBox(i,1)+dstBox(i,2)/2,dst(i),'HorizontalAlignment','left','FontSize',8);
end
axis([0 1 0 1]); axis off; hold off;
end

function boxes=sankeyBoxes(totals,usable)
gap=.018; heights=totals/sum(totals)*usable;
bottom=zeros(numel(totals),1); y=0;
for i=1:numel(totals), bottom(i)=y;
    y=y+heights(i)+gap; 
end
boxes=[bottom heights];
end