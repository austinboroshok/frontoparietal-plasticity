function [dat,keys] = keys_setup(dat)

KbName('UnifyKeyNames');

keys.space      = KbName('space');
keys.esc        = KbName('ESCAPE');
keys.coherent   = KbName('1!');
keys.random     = KbName('2@');

keys.isDown = 0;
keys.killed = 0;