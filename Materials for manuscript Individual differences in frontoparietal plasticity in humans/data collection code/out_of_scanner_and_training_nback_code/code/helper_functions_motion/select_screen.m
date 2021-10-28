function scr = select_screen(screen_in)

if isempty(screen_in)
    screen_name = input('Which screen are you using (provide name from screen_info file):','s');
else
    screen_name = screen_in{1};
end

scr  = screen_info(screen_name);
