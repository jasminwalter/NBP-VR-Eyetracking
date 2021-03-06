%% ---------------------- drawGraphMap ----------------------------------
% script written by Jasmin Walter

% draws graphs on map image of Seahaven

% requires file: Map_Houses_green_edges_New.jpg
% requires file: CoordinateListNew.txt

clear all;

savepath = 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\analysis\weightedGraphs\graphPlots_individual\';

cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\graphs_weighted\'

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21};% 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;

% load map

map = imread ('C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\Map_Houses_SW2.png');

% load house list with coordinates

listname = 'C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\CoordinateListNew.txt';
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};





for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_Graph_weighted_V3.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2

        % load graph      
        graphyW = load(file);
        graphyW= graphyW.graphyW;
        
        nodeTable = graphyW.Nodes;
        edgeTable = graphyW.Edges;
        edgeCell = edgeTable.EndNodes;
        weights = edgeTable.Weight;
                
        % display map
        figure(1)
        imshow(map);
        alpha 0.1;
        hold on;
        

        %% add edges into map---------------------------------------------
        
        % prepare colors for colormap
        maxW = max(weights);
        col = jet(maxW);       
        
        for ee = 1:length(edgeCell)
            [Xhouse,Xindex] = ismember(edgeCell(ee,1),coordinateList.House);
            
            [Yhouse,Yindex] = ismember(edgeCell(ee,2),coordinateList.House);
            
            x1 = (coordinateList{Xindex,2});
            y1 = coordinateList{Xindex,3};
            
            x2 = coordinateList{Yindex,2};
            y2 = coordinateList{Yindex,3};
            colIndex = weights(ee);
            
            line([x1,x2],[y1,y2],'LineWidth', 2, 'Color',col(colIndex,:));
                
            
        end
%---------comment code until here to only show nodes without edges--------
%% add nodes to graph
%         % to plot all houses on map use this code
%         plotty = scatter(coordinateList.X,coordinateList.Y,60,'filled','b');
        
        % mark node houses
        node = ismember(coordinateList.House,nodeTable.Name);
        x = coordinateList{node,2};
        y = coordinateList{node,3};


        plotty = scatter(x,y,60,'filled','k');
        title(strcat('Visualization of graph - projection on map - participant:',' ',num2str(currentPart)));
    
        colormap(col);
        t = [1:maxW];
        colorbar('Ticks',t/maxW,'TickLabels',t);

      saveas(gcf,strcat(savepath,'Visualization of graph - projection on map_participant ',num2str(currentPart),'.png'),'png');
  
    
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');