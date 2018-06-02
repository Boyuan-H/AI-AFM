function Cout(Name,type)
    
%     if filename==[]
        filename=Name;
%     end
    s1=['Make/O/N=1 wave0'];
    s2=['wave0 = ',type,'("',Name,'");'];
    s3=['Save/O/J wave0 as "C:/Users/Asylum User/Desktop/',filename,'.dat"'];
    ARcmd(s1);
    ARcmd(s2);
    ARcmd(s3); 
end