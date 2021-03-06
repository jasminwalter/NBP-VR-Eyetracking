%% ------------------fixated_vs_noise----------------------------------------
% script written by Jasmin Walter

% divides condensed viewed houses list based on a set sample value into 
% fixated and non-fixated objects
% in other words: devides condensed viewed houses list into seen houses and houses which
% were just glanced at

% uses condensedViewedHouses file as input
% output: list with seen houses per subject -> objects that were fixated
%         list with glanced houses per subject -> objects that were not fixated
%         overall overview with percentage of seen/glanced objects


clear all;

savepath = 'D:\BA Backup\Data_after_Script\fixated_vs_noise\';

cd 'D:\BA Backup\Data_after_Script\CondenseViewedHouses\'

% beforeFebruarData: PartList = {1882,1809,5699,1003,3961,6525,2907,5324,3430,4302,7561,6348,4060,6503,7535,1944,8457,3854,2637,7018,8580,1961,6844,1119,5287,3983,8804,7350,7395,3116,1359,8556,9057,4376,8864,8517,9434,2051,4444,5311,5625,1181,9430,2151,3251,6468,8665,4502,5823,2653,7666,8466,3093,9327,7670,3668,7953,1909,1171,8222,9471,2006,8258,3377,1529,9364,5583};
PartList = {1809,5699,6525,2907,5324,4302,7561,4060,6503,7535,1944,2637,8580,1961,6844,1119,5287,3983,8804,7350,7395,3116,1359,8556,9057,8864,8517,2051,4444,5311,5625,9430,2151,3251,6468,4502,5823,8466,9327,7670,3668,7953,1909,1171,8222,9471,2006,8258,3377,9364,5583};

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;
countAnalysedPart= 0;

overviewFixations = array2table(zeros(Number,4));
overviewFixations.Properties.VariableNames = {'Participant','totalAmount','Fixated','NotFixated'};


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_condensedViewedHouses.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        countAnalysedPart = countAnalysedPart +1;
        % load data
        AllSeen = load(file);
        AllSeen = AllSeen.AllSeen;
        
        % something was fixated when having more than 7 samples
        

        fixated = AllSeen.Looks > 7;

        
        fixatedObjects = AllSeen(fixated,:);
        
        noisyObjects = AllSeen(not(fixated),:);
              
        
        
        % save both tables
        save([savepath 'fixated_objects_' num2str(currentPart) '.mat'],'fixatedObjects');
        save([savepath 'noisy_data_' num2str(currentPart) '.mat'],'noisyObjects');
        
        % update overview with values
        
        overviewFixations.Participant(countAnalysedPart)= currentPart;
        overviewFixations.totalAmount(countAnalysedPart)= height(AllSeen);
        overviewFixations.Fixated(countAnalysedPart)= height(fixatedObjects);
        overviewFixations.NotFixated(countAnalysedPart) = height(noisyObjects);
        
     
  

        
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants in List'));
disp(strcat(num2str(countAnalysedPart), ' Participants analyzed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

save([savepath 'Overview_Fixations.mat'],'overviewFixations');
disp('saved Overview Fixations');

disp('done');