function [ibw_path,ibw_name,file_order] = Zoomin_scan(Base_name,file_order,spot_x,spot_y,pathfolder)

ScanSize = Cin('ScanSize','GV');
ARcmd('ShowXYSpotFunc("ShowXYSpotCheck_2",0)');
fprintf(2,'\n---------- Now let us zoom in on the red spot! ----------\n');

ScanSize = ScanSize/2;
PV('ScanSize',ScanSize);

dx_XOffset=(128-spot_y)/256*ScanSize*2;
dy_YOffset=(128-spot_x)/256*ScanSize*2;
    YOffset = Cin('Yoffset','GV');
    XOffset = Cin('Xoffset','GV');
    
PV('XOffset',XOffset+dx_XOffset);
PV('YOffset',YOffset+dy_YOffset);
    
pause(2);
ARcmd('ShowXYSpotFunc("ShowXYSpotCheck_2",0)');

ARcmd('DoScanFunc("DoScan_0")');
file_order=file_order+1;

ibw_name =[Base_name,num2str(file_order),'.ibw'];
ibw_path= [pathfolder,ibw_name];

while (exist(ibw_path,'file')==0)
    pause(20);
    disp([datestr(datetime('now')),'      Waiting for the zoom-in sacnning!',]);
end

disp('Zoom-in sacnning finished. ');

end