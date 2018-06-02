function str_value = GetBaseName( )
    
 
    s1=['make/T/O testTextWave'];
    s2=['testTextWave=Root:Packages:MFP3D:Main:Variables:BaseName'];
    s3=['Save/O/J testTextWave as "C:/Users/Asylum User/Desktop/Basename.txt"'];
    ARcmd(s1);
    ARcmd(s2);
    ARcmd(s3); 
    
    path=['C:/Users/Asylum User/Desktop/Basename.txt'];

    fileID = fopen(path, 'r');
    str_value = fgetl(fileID);
    disp(['Basename = ' , str_value]);
    
    fclose(fileID);
end