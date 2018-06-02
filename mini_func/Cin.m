function tline = Cin(Name,type)
    
    Cout(Name,type);
    
    path=['C:/Users/Asylum User/Desktop/',Name,'.dat'];

    fileID = fopen(path, 'r');
    str_value = fgetl(fileID);
    tline = str2double(str_value);
    disp([Name,'-',type , ' = ' , str_value]);
    
    fclose(fileID);
end
