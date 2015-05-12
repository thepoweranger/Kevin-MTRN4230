function cond = robBIND
%GREEN = ready to receive input
%YELLOW = busy
%RED = DC
%initialize c to empty
    c= '';
    
    c=sender('KNOK');
    
    %if succesfully send open receive
    pause(0.001);
    if strcmp(c,'GREEN') == 1
        
        c = receive();
    else
        c= 'RED';
    end
    
    
    if strcmp(c,'GREEN')== 1 
        cond = 'GREEN';
   
    elseif strcmp(c,'YELLOW')==1
        cond = 'YELLOW';
    else
        cond = 'RED';
%         errordlg('DISCONNECTED');
        
        
    end
       


