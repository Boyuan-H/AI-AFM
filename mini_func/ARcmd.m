function ARcmd(command)
% 	system(["C:\Program Files (x86)\WaveMetrics\Igor Pro Folder\Igor.exe" /X "Print ",command,""])
%     system(['"C:\Program Files (x86)\WaveMetrics\Igor Pro Folder\Igor.exe" /X "Print " ',command ,' " "'])
    system(['"C:\Program Files (x86)\WaveMetrics\Igor Pro Folder\Igor.exe" /X ',command]);
end