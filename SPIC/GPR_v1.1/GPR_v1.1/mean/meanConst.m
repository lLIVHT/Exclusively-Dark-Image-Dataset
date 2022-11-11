function A = meanConst(hyp, x, i)

% Constant mean function. The mean function is parameterized as:
%
% m(x) = c
%
% The hyperparameter is:
%
% hyp = [ c ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-10.
%
% See also MEANFUNCTIONS.M.

if nargin<2, A = '1'; return; end             % report number of hyperparameters 
if numel(hyp)~=1, error('Exactly one hyperparameter needed.'), end
c = hyp;
if nargin==2
    A = c*ones(size(x,1),1);                                     % evaluate mean
else
    A = ones(size(x,1),1);                                          % derivative
end
