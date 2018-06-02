function [Amp,Pha,Freq] = save_read_tune(driveamp_input,spot,harmonic)

Current_tune_name = ['V',num2str(driveamp_input),'S',num2str(spot),'H',num2str(harmonic)];
Tune_Wave_root = 'Save/O/J root:packages:MFP3D:Tune:';
Tune_save_path = ['C:/Users/Asylum User/Desktop/Pointwise_data/',Current_tune_name];

ARcmd([Tune_Wave_root,'Amp as "',Tune_save_path,'_Amp.dat"']);
ARcmd([Tune_Wave_root,'Phase as "',Tune_save_path,'_Pha.dat"']);
ARcmd([Tune_Wave_root,'frequency as "',Tune_save_path,'_Freq.dat"']);

F_Amp = fopen([Tune_save_path,'_Amp.dat'],'r');
Amp = fscanf(F_Amp,'%f');
F_Pha = fopen([Tune_save_path,'_Pha.dat'],'r');
Pha = fscanf(F_Pha,'%f');
F_Freq = fopen([Tune_save_path,'_Freq.dat'],'r');
Freq = fscanf(F_Freq,'%f');

fclose('all');
end