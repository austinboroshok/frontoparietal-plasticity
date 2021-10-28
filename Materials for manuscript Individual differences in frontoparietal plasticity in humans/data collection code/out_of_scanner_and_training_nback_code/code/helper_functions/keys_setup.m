function [dat,keys] = keys_setup(dat)

KbName('UnifyKeyNames');

keys.space      = KbName('space');
keys.esc        = KbName('ESCAPE');

keys.yes        = KbName(dat.scr.response_mapping(1));
keys.no         = KbName(dat.scr.response_mapping(2));

keys.isDown = 0;
keys.killed = 0;

