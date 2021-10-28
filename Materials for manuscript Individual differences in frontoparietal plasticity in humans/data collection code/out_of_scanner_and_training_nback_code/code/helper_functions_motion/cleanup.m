% Cleanup routine:
function cleanup(early,dat)

Priority(0);            % Shutdown realtime mode.
sca;                    % Close window:
ListenChar(1);          % Restore keyboard output to Matlab:
ShowCursor;             % Show cursor again, if it has been disabled.

if(early)
    store_results(dat);
    warning('Exited experiment before completion');
end

commandwindow;