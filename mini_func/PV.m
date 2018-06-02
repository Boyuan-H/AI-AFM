function PV(Name,value)
    command = ['print PV("',Name,'",',num2str(value),')'];
    ARcmd(command);
end