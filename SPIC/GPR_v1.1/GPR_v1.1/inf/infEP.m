function [post nlZ dnlZ] = infEP(hyp, mean, cov, lik, x, y)

% Expectation Propagation approximation to the posterior Gaussian Process.
% The function takes a specified covariance function (see covFunction.m) and
% likelihood function (see likFunction.m), and is designed to be used with
% gp.m. See also infFunctions.m. In the EP algorithm, the sites are 
% updated in random order, for better performance when cases are ordered
% according to the targets.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch 2010-02-25.

persistent last_ttau last_tnu              % keep tilde parameters between calls
tol = 1e-4; max_sweep = 10; min_sweep = 2;     % tolerance to stop EP iterations

if ~ischar(lik), lik = func2str(lik); end    % make likelihood variable a string
inf = 'infEP';
n = size(x,1);
K = feval(cov{:}, hyp.cov, x);                  % evaluate the covariance matrix
m = feval(mean{:}, hyp.mean, x);                      % evaluate the mean vector

% A note on naming: variables are given short but descriptive names in 
% accordance with Rasmussen & Williams "GPs for Machine Learning" (2006): mu
% and s2 are mean and variance, nu and tau are natural parameters. A leading t
% means tilde, a subscript _ni means "not i" (for cavity parameters), or _n
% for a vector of cavity parameters.

% marginal likelihood for ttau = tnu = zeros(n,1); equals n*log(2) for likCum*
nlZ0 = -sum(feval(lik, hyp.lik, y, m, diag(K), inf));
if any(size(last_ttau) ~= [n 1])      % find starting point for tilde parameters
  ttau = zeros(n,1);             % initialize to zero if we have no better guess
  tnu  = zeros(n,1);
  Sigma = K;                     % initialize Sigma and mu, the parameters of ..
  mu = zeros(n,1);                     % .. the Gaussian posterior approximation
  nlZ = nlZ0;
else
  ttau = last_ttau;                    % try the tilde values from previous call
  tnu  = last_tnu;
  [Sigma, mu, nlZ, L] = epComputeParams(K, y, ttau, tnu, lik, hyp, m, inf); 
  if nlZ > nlZ0                                           % if zero is better ..
    ttau = zeros(n,1);                    % .. then initialize with zero instead
    tnu  = zeros(n,1); 
    Sigma = K;                   % initialize Sigma and mu, the parameters of ..
    mu = zeros(n,1);                   % .. the Gaussian posterior approximation
    nlZ = nlZ0;
  end
end

nlZ_old = Inf; sweep = 0;               % converged, max. sweeps or min. sweeps?
while (abs(nlZ-nlZ_old) > tol && sweep < max_sweep) || sweep<min_sweep
  nlZ_old = nlZ; sweep = sweep+1;
  for i = randperm(n)       % iterate EP updates (in random order) over examples
    tau_ni = 1/Sigma(i,i)-ttau(i);      %  first find the cavity distribution ..
    nu_ni = mu(i)/Sigma(i,i)+m(i)*tau_ni-tnu(i);    % .. params tau_ni and nu_ni
   
    % compute the desired derivatives of the indivdual log partition function
    [lZ, dlZ, d2lZ] = feval(lik, hyp.lik, y(i), nu_ni/tau_ni, 1/tau_ni, inf);
    ttau_old = ttau(i);   % then find the new tilde parameters, keep copy of old
    
    ttau(i) =                            -d2lZ  /(1+d2lZ/tau_ni);
    ttau(i) = max(ttau(i),0); % enforce positivity i.e. lower bound ttau by zero
    tnu(i)  = ( dlZ + (m(i)-nu_ni/tau_ni)*d2lZ )/(1+d2lZ/tau_ni);
    
    ds2 = ttau(i) - ttau_old;                   % finally rank-1 update Sigma ..
    si = Sigma(:,i);
    Sigma = Sigma - ds2/(1+ds2*si(i))*si*si';          % takes 70% of total time
    mu = Sigma*tnu;                                        % .. and recompute mu
  end
  % recompute since repeated rank-one updates can destroy numerical precision
  [Sigma, mu, nlZ, L] = epComputeParams(K, y, ttau, tnu, lik, hyp, m, inf);
end

% if sweep == max_sweep
%   error('maximum number of sweeps reached in function infEP')
% end

last_ttau = ttau; last_tnu = tnu;                       % remember for next call

sW = sqrt(ttau); alpha = tnu-sW.*solve_chol(L,sW.*(K*tnu));
post.alpha = alpha;                                % return the posterior params
post.sW = sW;
post.L  = L;

if nargout>2                                           % do we want derivatives?
  dnlZ = hyp;                                   % allocate space for derivatives
  ssi = sqrt(ttau);
  V = L'\(repmat(ssi,1,n).*K);
  Sigma = K - V'*V;
  mu = Sigma*tnu;
  tau_n = 1./diag(Sigma)-ttau;             % compute the log marginal likelihood
  nu_n  = mu./diag(Sigma)-tnu;                    % vectors of cavity parameters

  F = alpha*alpha'-repmat(sW,1,n).*solve_chol(L,diag(sW));   % covariance hypers
  for j=1:length(hyp.cov)
    dK = feval(cov{:}, hyp.cov, x, j);
    dnlZ.cov(j) = -sum(sum(F.*dK))/2;
  end
  for i = 1:numel(hyp.lik)                                   % likelihood hypers
    dlik = feval(lik, hyp.lik, y, nu_n./tau_n+m, 1./tau_n, inf, i);
    dnlZ.lik(i) = -sum(dlik);
  end
  [junk,dlZ] = feval(lik, hyp.lik, y, nu_n./tau_n+m, 1./tau_n, inf); % mean hyps
  for i = 1:numel(hyp.mean)
    dmean = feval(mean{:}, hyp.mean, x, i);
    dnlZ.mean(i) = -dlZ'*dmean;
  end
end

% function to compute the parameters of the Gaussian approximation, Sigma and
% mu, and the negative log marginal likelihood, nlZ, from the current site
% parameters, ttau and tnu. Also returns L (useful for predictions).
function [Sigma mu nlZ L] = epComputeParams(K, y, ttau, tnu, lik, hyp, m, inf)
n = length(y);                                        % number of training cases
ssi = sqrt(ttau);                                         % compute Sigma and mu
L = chol(eye(n)+ssi*ssi'.*K);                            % L'*L=B=eye(n)+sW*K*sW
V = L'\(repmat(ssi,1,n).*K);
Sigma = K - V'*V;
mu = Sigma*tnu;

tau_n = 1./diag(Sigma)-ttau;               % compute the log marginal likelihood
nu_n  = mu./diag(Sigma)-tnu+m.*tau_n;             % vectors of cavity parameters
lZ = feval(lik, hyp.lik, y, nu_n./tau_n, 1./tau_n, inf);
nlZ = sum(log(diag(L))) -sum(lZ) -tnu'*Sigma*tnu/2  ...
    -(nu_n-m.*tau_n)'*((ttau./tau_n.*(nu_n-m.*tau_n)-2*tnu)./(ttau+tau_n))/2 ...
    +sum(tnu.^2./(tau_n+ttau))/2-sum(log(1+ttau./tau_n))/2;
