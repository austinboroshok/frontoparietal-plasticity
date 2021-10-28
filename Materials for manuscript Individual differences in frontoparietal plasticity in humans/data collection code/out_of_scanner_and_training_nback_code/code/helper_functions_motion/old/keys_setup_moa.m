function [dat,keys] = keys_setup_moa(dat)

KbName('UnifyKeyNames');

keys.space      = KbName('space');
keys.enter      = KbName('Return');
keys.esc        = KbName('ESCAPE');
keys.big_up     = KbName('1!');
keys.big_down   = KbName('2@');

keys.isDown = 0;
keys.killed = 0;