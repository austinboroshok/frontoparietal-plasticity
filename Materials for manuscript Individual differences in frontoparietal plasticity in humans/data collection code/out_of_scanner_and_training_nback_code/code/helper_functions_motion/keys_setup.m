function [dat,keys] = keys_setup(dat)

KbName('UnifyKeyNames');

keys.space      = KbName('space');
keys.esc        = KbName('ESCAPE');

keys.upright        = KbName(dat.scr.response_mapping(1));
keys.upleft         = KbName(dat.scr.response_mapping(2));
keys.downleft       = KbName(dat.scr.response_mapping(3));
keys.downright      = KbName(dat.scr.response_mapping(4));

keys.isDown = 0;
keys.killed = 0;

% keys.up         = KbName('UpArrow');
% keys.down       = KbName('DownArrow');
% keys.left       = KbName('LeftArrow');
% keys.right      = KbName('RightArrow');
% keys.coherent   = KbName('1!');
% keys.random     = KbName('2@');

