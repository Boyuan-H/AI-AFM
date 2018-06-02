function MoveTip(X_pixel,Y_pixel,ScanSize)
    
    X_position=X_pixel/256*ScanSize; 
    Y_position=(256-Y_pixel)/256*ScanSize;
    ARcmd('ShowXYSpotFunc("ShowXYSpotCheck_2",1)');
    
    Move_cmd = ['ARGo2ImagePos(',num2str(X_position),',',num2str(Y_position),')'];
    
    % 	//To Withdraw the tip:
    ARcmd('DoScanFunc("Withdraw_2")');

    % then we need to wait 2 seconds before going to the position
    pause(2);

    ARcmd(Move_cmd);% 	
    
    %  //To start up the Simple engage:
    % ARcmd('SimpleEngageMe("")');
end
