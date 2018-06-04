%% if it is electrochemical material
addpath 'C:\Users\User\Desktop\AIAFM\mini_func'; % Plz make sure this path correct
line_length=[-16 -8 -4 -2  0  2 4 8 16];


%% Find GBs
fprintf(2,'\n---------- No FE domain is found. The material may be non-FE! ----------\n');
disp('---------- Let us highlight grain boundaries and do pointwise measurements. ---------- ');
[spot_x,spot_y,~,~] = IsGB(ibw_path,line_length);
ARcmd('DoScanFunc("StopScan_0")');
pause(2);

%% Zoom in and check GBs again

[ibw_path,ibw_name,~] = Zoomin_scan(Base_name,file_order,spot_x,spot_y,pathfolder);

figure;
    scrsz = get(0,'ScreenSize');
    set(gcf,'Position',scrsz);
[spot_x,spot_y,Ang_x,Ang_y] = IsGB(ibw_path,line_length);
pause(5);
set(gcf,'position',[125,52,910,300]);

ScanSize = Cin('ScanSize','GV');
MoveTip2(spot_x,spot_y,ScanSize);
% fprintf(2,'\n----------  The tip (red spot) is now close to grain boundary.  ----------\n');
pause(5);

%% Switch to single frequency PFM mode 
ARcmd('ModeMasterLoadProfile("SingleFreqPFM",0)');%print 
disp('---------- Switch to single frequency PFM mode ---------- ');
pause(7);

% ARcmd('String GraphStr_MCP = "MasterChannelPanel"');
% ARcmd('DoWindow/B $GraphStr_MCP'); %DoWindow/F
ARcmd('ARCheckFunc("DualACModeBox_3",1)'); % tunr dual AC on
pause(1);
ARcmd('ARKillWindow("MasterPanel")');
pause(2);
ARcmd('MakePanel("Master")');
pause(2);
ARcmd('MoveWindow/W=$"MasterChannelPanel" 10,350,220,590');
pause(2);
ARcmd('ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")');
pause(5);

ARcmd('TabFunc("MasterTab","MasterPanel",3)');
ARcmd('MoveWindow/W=$"TuneGraph" 750,50,1200,350');
ARcmd('MoveWindow/W=$"MasterPanel" 1220,50,1500,350');
ARcmd('MoveWindow/W=$"MeterPanel" 10,50,300,220');
ARcmd('root:Packages:MFP3D:Tune:DoNXTune=1');

% These can be set automatically with more codes. 
DriveFrequency = 250e3;
DriveFrequency1 = 250e3;
DriveAmplitude = 0;
DriveAmplitude1 = 1;
% FittWidth_input=200;
Tunetime=3;

%left right drive

PV('DriveFrequency',DriveFrequency);
PV('DriveFrequency1',DriveFrequency1);
PV('DriveAmplitude',DriveAmplitude);
PV('DriveAmplitude1',DriveAmplitude1);
PV('Tunetime',Tunetime);


%% Do pointwise 

% test moving tip

% for spot=1:2:length(line_length)
%     
%     spot_index = spot_index+1;
%     disp(['Move to the spot:',num2str(spot_index),'.']);
%     
%     ptws_x=round(spot_x+line_length(spot)*Ang_x*2);
%     ptws_y=round(spot_y+line_length(spot)*Ang_y*2);
% 
%     MoveTip2(ptws_x,ptws_y,ScanSize);
%     
% end

spot_index = 0;
for spot=1:2:length(line_length)
    
    spot_index = spot_index+1;
    disp(['Move to the spot:',num2str(spot_index),'.']);
    
    ptws_x=spot_x+line_length(spot)*Ang_x*2;
    ptws_y=spot_y+line_length(spot)*Ang_y*2;

    MoveTip2(ptws_x,ptws_y,ScanSize);
    
    drive_index1=0;
    drive_index2=0;
    
    for driveamp_input = 1:0.4:5.4
        
        disp(['--- Drive voltage = ' ,num2str(driveamp_input) ,' V' ]);
        
        for harmonic = 1:2
            
            if (harmonic == 1)
                disp(['--- 1st harmonic...']);
                drive_index1 = drive_index1+1;
                drive_index=drive_index1;
            else
                disp(['--- 2nd harmonic...']);
                drive_index2 = drive_index2+1;
                drive_index=drive_index2;
            end
            
            % Set harmonic
            ARcmd(['ARExecuteControl("FrequencyRatioSetVar_3", "MasterPanel",',num2str(1/harmonic),',"")']);
            pause(4);
            
           
            % Change the Voltage
            PV('DriveAmplitude1',driveamp_input);
            
            ARcmd('ARExecuteControl("DoTuneOnce_3", "MasterPanel", 0, "")');
            pause(5);

            [Amp,Pha,Freq] = save_read_tune(driveamp_input,spot,harmonic);

            Pointwise_data(1,harmonic,drive_index,spot_index,:) = Amp;
            Pointwise_data(2,harmonic,drive_index,spot_index,:) = Pha;
            Pointwise_data(3,harmonic,drive_index,spot_index,:) = Freq;
            
        end
        
    end
    
    save('isESM_data.mat','Pointwise_data');

end

disp('Pointwise measurements are done.');