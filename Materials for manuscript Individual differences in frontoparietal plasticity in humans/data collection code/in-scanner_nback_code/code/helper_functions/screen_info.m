function scr = screen_info(screen_name)
%
% get info for experiment screen

scr.name  = screen_name;

switch screen_name
 
    case 'emilyOffice'
        
        scr.screenNumber        = 1;        % Use max screen number - 0 for primary screen or single screen set ups, 1 for secondary screen (only if 2 screen are enabled)
        
        scr.widthCm             = 37.6;   	% display width (cm)
        scr.heightCm            = 30.15;   	% display height (cm)
        scr.skipSync            = 0;        % whether to skip timing tests, generally unwise to skip unless there is a known issue with tehm
        
        scr.fontSize = 33;
        
        % keys used to indicate directions in this order: (1) up right, (2) up left, (3) down left, (4) down right
        scr.response_mapping    = {'f','j'};
        
    case 'emilyOfficeHD'
        
        scr.screenNumber        = 0;                             
        scr.widthCm             = 50.92;                         
        scr.heightCm            = 28.64;                     
        scr.skipSync            = 0;
        
        scr.fontSize = 33;
        
        scr.response_mapping    = {'f','j'};
        
    case 'emilyLaptop'
        
        scr.screenNumber        = 0;                                  
        scr.widthCm             = 33;                          
        scr.heightCm            = 20.5;                          
        scr.skipSync            = 1;
        
        scr.fontSize = 33;
        
        scr.response_mapping    = {'f','j'};
        
    case 'Mackeyfmri' %do not use with Stellar Chance FMRI 
        scr.screenNumber        = 1; %if computer in fMRI uses an external screen, not sure how that works yet                              
        scr.widthCm             = 26;   %need to figure out                       
        scr.heightCm            = 16.2; %need to figure out                      
        scr.skipSync            = 0;
        
        scr.fontSize = 28; %Need to test with fMRI. 
        
        scr.response_mapping    = {'r','y'}; %arbitrary right now based on button press colors, can change
    case 'MackeyLaptop'
        
        scr.screenNumber        = 0;                             
        scr.widthCm             = 26;                         
        scr.heightCm            = 16.2;                     
        scr.skipSync            = 1;
        
        scr.fontSize = 40;
        
        scr.response_mapping    = {'y','b'};    
        
    case 'MackeyHD' %changed scr.screenNumber to 1 for dual screen use
        
        scr.screenNumber        = 1;                                
        scr.widthCm             = 47.5;                          
        scr.heightCm            = 27;                          
        scr.skipSync            = 0;
        
        scr.fontSize = 33;
        
        scr.response_mapping    = {'1','2'};
        
    case 'emilyLab'
        
        scr.screenNumber        = 2;                                
        scr.widthCm             = 51;                          
        scr.heightCm            = 28.8;                          
        scr.skipSync            = 1;
        
        scr.fontSize = 33;
        
        scr.response_mapping    = {'f','j'};

    otherwise
        
        error('screen name provided does not exist. add screen to screen_info file in helper_functions');
        
end
