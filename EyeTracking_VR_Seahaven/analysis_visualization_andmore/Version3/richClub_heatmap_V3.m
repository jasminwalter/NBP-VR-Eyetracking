%% ------------------ rich club heatmap Version 3-------------------------------------
% script written by Jasmin Walter

clear all;


savepath= 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\analysis\all_participants\position\top10_houses\';


cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\analysis\all_participants\'


%houses = {'008_0','007_0', '004_0'};

disp('load data')
% load data

gazes_allParts = load('gazes_allParticipants.mat');
gazes_allParts = gazes_allParts.gazes_allParticipants;

disp('data loaded')

% load map

map = imread ('C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\Map_Houses_SW2.png');
% load house list with coordinates

listname = 'C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\CoordinateListNew.txt';
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};



overviewNodeDegree = load('E:\NBP\SeahavenEyeTrackingData\90minVR\analysis\graphs\node_degree\Overview_NodeDegree.mat');
overviewNodeDegree = overviewNodeDegree.overviewNodeDegree; 

overviewNodeDegree.Mean = mean(overviewNodeDegree{:,2:end},2);
overviewSorted = sortrows(overviewNodeDegree, 'Mean', 'ascend');


%%  transformation - 2 factors (mulitply and additive factor)
xT = 6.05;
zT = 6.1;
xA = -1100;
zA = -3290;



%% rich club


RCHouseList = readtable("E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\analysis\all_participants\position\top10_houses\RC_HouseList.csv");

sortedRCL = sortrows(RCHouseList,'RCCount','ascend');

housesTop10RC = sortedRCL{end-9:end,1};

houseIndex10 = ismember({gazes_allParts.Collider}, housesTop10RC);
positions10 = table;
positions10.X = [gazes_allParts(houseIndex10).PosX]'*xT+xA;
positions10.Z = [gazes_allParts(houseIndex10).PosZ]'*zT+zA;


% define grid and do hist count
[rows, columns, numberOfColorChannels] = size(map);

% % ca 5m x 5m
% edgesRows = linspace(1,rows,100);
% edgesCol = linspace(1,columns,90);

% ca 4m x 4m
edgesRows = linspace(1,rows,125);
edgesCol = linspace(1,columns,112);

[countMatrix,colEdges,rowEdges] = histcounts2(positions10.Z, positions10.X, edgesCol,edgesRows);
% 
% % plot countMatrix
% figure(3);
% imshow(map);
% %alpha(0.1)
% 
% hold on
% plottyT = imagesc(colEdges,rowEdges,countMatrix', 'AlphaData', 0.7);
% colorbar
% 
% figure(4)
% imshow(map)
% figure(5)
% plottyT = imagesc(colEdges,rowEdges,countMatrix', 'AlphaData', 0.7);
% 
% figure(6)
% imshow(map);
% alpha(0.1)
% hold on
% scatty = scatter(positions10.Z, positions10.X, 4, 'filled');
% 

%% now the real thing
fullCount = struct;

for index = 1:length(housesTop10RC)
        
    houseName = housesTop10RC{index};
    houseIndex = strcmp({gazes_allParts.Collider}, houseName);
    positions = table;
    positions.X = [gazes_allParts(houseIndex).PosX]'*xT+xA;
    positions.Z = [gazes_allParts(houseIndex).PosZ]'*zT+zA;
    
    [countMatrix,colEdges,rowEdges] = histcounts2(positions.Z, positions.X, edgesCol,edgesRows);
    fullCount(index).columnEdges = colEdges;
    fullCount(index).rowEdges = rowEdges;
    fullCount(index).countMatrix = countMatrix;
 
end
% apply kernal smoothing / convolution
kernel  = [1,1,1;1,1,1;1,1,1];
convCount = fullCount;


for index11 = 1:length(fullCount)

    convCount(index11).countMatrix = conv2(convCount(index11).countMatrix,kernel,'same');
end

logicalCount = convCount;

for index2 = 1:length(fullCount)

    logicalCount(index2).countMatrix = convCount(index2).countMatrix > 0;
 
end

logicalCell = struct2cell(logicalCount);

logical3D = [];

for index3 = 1:length(fullCount)
    logical3D(:,:,index3) = logicalCell{3,1,index3};
    
end


sumAll = sum(logical3D,3);

% plot the summed matrix
colours = [ 0.24,0.15,0.66;0.01,0.72,0.80;0.96,0.73,0.23];

figure(10)
imshow(map);
hold on
plotty10 = imagesc(colEdges,rowEdges,sumAll', 'AlphaData', 0.7);
colorbar
title('visibility of top 10 houses - rich club and node degree');
% saveas(gcf, strcat(savepath, 'visibility of top 10 houses.png'));
hold off

%% final aspect - only display 0,1,2 or more

more3 = sumAll >= 2;

sumAll3cut = sumAll;
sumAll3cut(more3) = 2;

colormap3 = [
    0.24,0.15,0.66
    0.18,0.77,0.64
    0.97,0.85,0.17];

figure(11)
imshow(map);
hold on
plotty11 = imagesc(colEdges,rowEdges,sumAll3cut', 'AlphaData', 0.7);
colormap(colormap3);
colorbar('Ticks',[0.35,1,1.65], 'TickLabels',{'0 houses','1 house','2 or more houses'})
title('Visibility of top 10 houses - rich club & node degree');

% saveas(gcf, strcat(savepath, 'visibility of top 10 houses - Triangulation.png'));
% saveas(gcf, strcat(savepath, 'visibility of top 10 houses - Triangulation.fig'));

hold off

h1(:,1)= rowEdges';
h1(:,2) = 0;

h2(:,1)= rowEdges';
h2(:,1)= rowEdges';
% bin plot
figure(12)
imshow(map);
% xticks(colEdges)
% yticks(rowEdges)
% grid minor


% [rows, columns, numberOfColorChannels] = size(map);

stepSize = 30; % Whatever you want.
for row = 1 : length(rowEdges)
    line([1, 2700], [rowEdges(row), rowEdges(row)], 'Color', 'r', 'LineWidth', 0.1);
end
for col = 1 : length(colEdges)
    line([colEdges(col), colEdges(col)], [1, 3000], 'Color', 'r', 'LineWidth', 0.1);
end
% saveas(gcf, strcat(savepath, 'grid size_vibility plots.png'));


%% percentage of triangulation are vs walked area

positionsAll = table;
positionsAll.X = [gazes_allParts.PosX]'*xT+xA;
positionsAll.Z = [gazes_allParts.PosZ]'*zT+zA;


[countMatrixAll,colEdgesAll,rowEdgesAll] = histcounts2(positionsAll.Z, positionsAll.X, edgesCol,edgesRows);

walkedGridAll = countMatrixAll ~= 0;
sumGridAll = sum(walkedGridAll,'all');

saw1 = sumAll3cut == 1;
saw2 = sumAll3cut == 2;

sumGrid1 = sum(saw1, 'all');
sumGrid2 = sum(saw2, 'all');

figure(20)
figgy20 = pie([sumGridAll-sumGrid1-sumGrid2, sumGrid1, sumGrid2]);
