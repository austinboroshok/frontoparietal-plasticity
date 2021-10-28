% DPRIME  - Signal-detection theory sensitivity measure.
%
%  d = dprime(pHit,pFA,nTrials)
%  [d,beta] = dprime(pHit,pFA,nTrials)
%
%  PHIT and PFA are numerical arrays of the same shape.
%  PHIT is the proportion of "Hits":        P(Yes|Signal)
%  PFA is the proportion of "False Alarms": P(Yes|Noise)
%  All numbers involved must be between 0 and 1.
%  nTrials is the number of trials used to calculate pHit
%     -can be either a matrix/vector with the same number of elements as
%     PHit, or a single number that is treated as the same number of trials
%     for all phits
%  The function calculates the d-prime measure for each <H,FA> pair.
%  The criterion value BETA can also be requested.
%  Requires MATLAB's Statistical Toolbox.
%
%  References:
%  * Green, D. M. & Swets, J. A. (1974). Signal Detection Theory and
%    Psychophysics (2nd Ed.). Huntington, NY: Robert Krieger Publ.Co.
%  * Macmillan, Neil A. & Creelman, C. Douglas (2005). Detection Theory:
%    A User's Guide (2nd Ed.). Lawrence Erlbaum Associates.
%  
%  See also NORMINV, NORMPDF.

% Original coding by Alexander Petrov, Ohio State University.
% $Revision: 1.2 $  $Date: 2009-02-09 10:49:29 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement:

% GNU Public License for the UTILS Toolbox
% 
function [d,beta] = dprime(pHit,pFA,nTrials)

%TODO implement error checking pHit/pFA of 0 or 1 will lead to d' of
%-Inf/Inf

%-- Replace any 0s and 1s with approximations
maxvals = (nTrials-0.5)./nTrials;
minvals = 0.5./nTrials;

if numel(minvals) > 1
    pFA(pFA <= 0) = minvals(pFA <= 0);
    pFA(pFA >= 1) = maxvals(pFA >= 1);
    
    pHit(pHit <= 0) = minvals(pHit <= 0);
    pHit(pHit >= 1) = maxvals(pHit >= 1);
else
    pFA(pFA <= 0) = minvals;
    pFA(pFA >= 1) = maxvals;
    
    pHit(pHit <= 0) = minvals;
    pHit(pHit >= 1) = maxvals;
end

%-- Convert to Z scores
zHit = norminv(pHit) ;
zFA  = norminv(pFA) ;

%-- Calculate d-prime
d = zHit - zFA ;

%-- If requested, calculate BETA
if (nargout > 1)
  yHit = normpdf(zHit) ;
  yFA  = normpdf(zFA) ;
  %beta = yHit ./ yFA ;
  
  beta = -(zHit + zFA)/2; % actually c, criterion
  
  %beta = exp((zFA.^2 - zHit.^2)/2);
end

%%  Return DPRIME and possibly BETA
%%%%%% End of file DPRIME.M