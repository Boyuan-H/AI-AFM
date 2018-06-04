clc;
clear all;
addpath 'C:\Users\User\Desktop\AIAFM\mini_func'; % Plz make sure this path correct
load('DB_SVM_results_ESM.mat','SVMModels_Amp','SVMModels_Pha');
pathfolder = 'C:\Users\Asylum User\Google Drive\Asylum User\180528\'; % Plz replace this with the folder path of new scanning data 
line_length=[-16 -8 -4 -2  0  2 4 8 16];


% Preparation before using this code. Plz make sure:
% 1. Master panel --> last frame
% 2. For simplicity, plz set the suffix=100, Xoffset>1 micron, and Yoffset>1 micron

%% 1. Find good area (longest DB line > 55)
ARcmd(['DoScanFunc("DoScan_0")']);
pause(15);
file_order=Cin('BaseSuffix','GV'); % get the current suffix from AFM
Base_name=GetBaseName();% get the current basename from AFM
Base_name=[Base_name,'0'];

fprintf(2,'\n---------- Waiting for this scanning! ----------\n');
disp('---------- Begin to search ferroelectric domain ... ---------- ');

    if(Cin('Yoffset','GVU')~=1e-6 || Cin('Xoffset','GVU')~=1e-6 )
        disp('---------- Warning: units are not um !!!! ---------- ');
        return;
    end
    

ibw_name =[Base_name,num2str(file_order),'.ibw'];
ibw_path= [pathfolder,ibw_name];

    while (exist(ibw_path,'file')==0)        
        pause(5);
        disp([datestr(datetime('now')),'       Waiting for sacnning!',]);
    end
    
figure;
scrsz = get(0,'ScreenSize');
set(gcf,'position',[525,552,1110,500]);

%Identify possible DWs in the last scan.
[isferro, spot_x , spot_y,~,~] = IsFerro(SVMModels_Amp,SVMModels_Pha,ibw_path,ibw_name,line_length);

pause(5);
set(gcf,'position',[125,52,910,300]);

Scan_num=0;   
while (isferro==0) % Repeat scanning if the no DWs is found.
    Scan_num = Scan_num + 1;
    
     % The number could be changed. Here, 1 means that we only once. If the
     % last map has no 180 DW, AI will determine it to be electrochemical
     % material.
    if (Scan_num>=1)
        run IsESM;
        return;
    end
    
    YOffset = Cin('Yoffset','GV');
    XOffset = Cin('Xoffset','GV');
    
    disp('Did not find FE domain, ');
    disp(['So let us move to the neighbor area',...
        '(XOffset = ',num2str(XOffset) '; YOffset=',num2str(YOffset), ') ...']);
    
    ARcmd(['DoScanFunc("StopScan_0")']);
    
    % change X or Y offset to scan a new area
    if (abs(XOffset)<34e-6)
       PV('XOffset',XOffset+5e-6);
    else
       PV('XOffset',-35e-6);
       PV('YOffset',YOffset+5e-6);
       
       if(YOffset>30e-6)
           disp('No FE domain was found. Exit().');  
           run IsESM;
           return;
       end
    end
    
    % ask AFM to do a new scan
    ARcmd('DoScanFunc("DoScan_0")');
    
    file_order=file_order+1;
    ibw_name =[Base_name,num2str(file_order),'.ibw'];
    ibw_path= [pathfolder,ibw_name];
    
    while (exist(ibw_path,'file')==0)        
        pause(20);
        disp([datestr(datetime('now')),'       Waiting for sacnning!',]);
    end
    
    fclose('all');
    
    %Identify possible DWs in the last scan.
    [isferro, spot_x , spot_y,~,~] = IsFerro(SVMModels_Amp,SVMModels_Pha,ibw_path,ibw_name,line_length); % get x,y offset
end

disp('---------- Found FE domain! ---------- ');
ARcmd('DoScanFunc("StopScan_0")'); % Stop the scanning
pause(2);

ScanSize = Cin('ScanSize','GV'); % get the scanning size
MoveTip(spot_x,spot_y,ScanSize);
% fprintf(2,'\n---------- The tip (Red spot) is now on the domain wall. ----------\n');
pause(5);


%% 2. Zoom in on interested area

[ibw_path,ibw_name,file_order] = Zoomin_scan(Base_name,file_order,spot_x,spot_y,pathfolder);
figure;
    scrsz = get(0,'ScreenSize');
    set(gcf,'Position',scrsz);
[isferro,spot_x,spot_y,Ang_x,Ang_y] = IsFerro(SVMModels_Amp,SVMModels_Pha,ibw_path,ibw_name,line_length);

pause(5);
set(gcf,'position',[125,52,910,300]);

MoveTip2(spot_x,spot_y,ScanSize);
fprintf(2,'\n----------  The tip (red spot) is now close to the domain wall.  ----------\n');

%% 3. Do SS-PFM (For loop: move tip and then Force)

PV('DriveAmplitude',1.5);
PV('DARTIGain',20);
ScanSize = Cin('ScanSize','GV');


% test moving tip
spot_index=0;
for i=1:2:length(line_length)
    
    spot_index = spot_index+1;
    disp(['Move to the spot:',num2str(spot_index),'.']);
    
    sspfm_x=spot_x+line_length(i)*Ang_x*2
    sspfm_y=spot_y-line_length(i)*Ang_y*2

    MoveTip2(sspfm_x,sspfm_y,ScanSize);
    
end

% Do SS-PFM
for i=1:2:length(line_length)
    
    disp('Move to the next spot.');
    
    sspfm_x=spot_x+line_length(i)*Ang_x*2;
    sspfm_y=spot_y-line_length(i)*Ang_y*2;

    MoveTip2(sspfm_x,sspfm_y,ScanSize);
    
    file_order=file_order+1;
    PV('BaseSuffix',file_order);
            pause(5);
	ARcmd('DoForceFunc("SingleForce_0")');
    disp('---------- Doing SS-PFM ---------- ');  
    
    
    ibw_name =[Base_name,num2str(file_order),'.ibw'];
    ibw_path= [pathfolder,ibw_name];
    disp(ibw_path);
    
    while (exist(ibw_path,'file')==0)        
        pause(10);
        disp([datestr(datetime('now')),'       Waiting for SS-PFM!',]);
    end
    
    % Open files and calculate hystersis loops
    system(ibw_path);
    pause(9);
    ARcmd('Execute/P/Q/Z "PZTHystLoop()"');
    pause(9);
     
end

% Recover setting for other scanning
pause(5);
    PV('DARTIGain',2000);
    PV('DriveAmplitude',2.5);
    PV('ScanSize',2.5e-6);

disp('SS-PFM is done.');

