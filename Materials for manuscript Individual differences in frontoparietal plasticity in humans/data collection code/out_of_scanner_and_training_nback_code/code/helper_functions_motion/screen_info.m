function scr = screen_info(screen_name)
%
% get info for experiment screen

scr.name  = screen_name;

switch screen_name
    
    case 'emilyOffice'
        
        scr.screenNumber        = 1;        % Use max screen number - 0 for primary screen or single screen set ups, 1 for secondary screen (only if 2 screen are enabled)
        
        scr.viewDistCm          = 75;       % distance subject views screen from
        scr.widthCm             = 37.6;   	% display width (cm)
        scr.heightCm            = 30.15;   	% display height (cm)
        scr.skipSync            = 0;        % whether to skip timing tests, generally unwise to skip unless there is a known issue with tehm
        
        % keys used to indicate directions in this order: (1) up right, (2) up left, (3) down left, (4) down right
        scr.response_mapping    = {'u','r','c','m'};
        
        scr.letter_intensity_difference = 80; % number less than 106, smaller numbers should make the letter task harder
            
    case 'emilyOfficeHD'
        
        scr.screenNumber        = 0;      
        scr.viewDistCm          = 60;                         
        scr.widthCm             = 50.92;                         
        scr.heightCm            = 28.64;                     
        scr.skipSync            = 0;
        
        scr.response_mapping    = {'u','r','c','m'};
        
        scr.letter_intensity_difference = 80; % number less than 106, smaller numbers should make the letter task harder
        
    case 'emilyLaptop'
        
        scr.screenNumber        = 0;      
        scr.viewDistCm          = 57;                            
        scr.widthCm             = 33;                          
        scr.heightCm            = 20.5;                          
        scr.skipSync            = 1;
        
        scr.response_mapping    = {'u','r','c','m'};
        
        scr.letter_intensity_difference = 80; % number less than 106, smaller numbers should make the letter task harder
        
    case 'MackeyLaptop'
        
        scr.screenNumber        = 0;      
        scr.viewDistCm          = 60;                         
        scr.widthCm             = 26;                         
        scr.heightCm            = 16.2;                     
        scr.skipSync            = 0;
        
        scr.response_mapping    = {'u','r','c','m'};
        
        scr.letter_intensity_difference = 80; % number less than 106, smaller numbers should make the letter task harder
        
    case 'MackeyHD' %changed scr.screenNumber to 1 for dual screen use
        
        scr.screenNumber        = 1;      
        scr.viewDistCm          = 57;                            
        scr.widthCm             = 47.5;                          
        scr.heightCm            = 27;                          
        scr.skipSync            = 0;
        
        scr.response_mapping    = {'9','7','1','3'};
        
        scr.letter_intensity_difference = 80; % number less than 106, smaller numbers should make the letter task harder

    case 'emilyLab'
        
        scr.screenNumber        = 2;      
        scr.viewDistCm          = 57;                            
        scr.widthCm             = 51;                          
        scr.heightCm            = 28.8;                          
        scr.skipSync            = 1;
        
        scr.response_mapping    = {'u','r','c','m'};
        
        scr.letter_intensity_difference = 50; % number less than 106, smaller numbers should make the letter task harder
        
    otherwise
        
        error('screen name provided does not exist. add screen to screen_info file in helper_functions');
        
end
