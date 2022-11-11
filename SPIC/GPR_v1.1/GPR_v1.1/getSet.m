% Module Leader:	Prof. W.C. Siu, PhD, CEng, FIEE, FHKIE, FIEEE, Chair Professor
% Student:	Ms. He He, BEng (Hons)
%
%Please cite the paper when you use the code
%
% He He; Wan-Chi Siu; , "Single image super-resolution using Gaussian process regression," 
% Proceedings of 2011 IEEE Conference on Computer Vision and Pattern Recognition (CVPR), pp.449-456, 20-25 June 2011
%
% Copyright (C) 2012 Centre for Signal Processing, Department of Electronic and Information Engineering, The Hong Kong Polytechnic University
% All rights reserved.
%
%
function [X, y] = getSet(p2,p)

[M N] = size(p2);

X = zeros((M-2)*(N-2),8);
y = zeros((M-2)*(N-2),1);

%diag
X(:,1) = reshape(p2(1:M-2,1:N-2),[],1);
X(:,2) = reshape(p2(1:M-2,3:N),[],1);
X(:,3) = reshape(p2(3:M,1:N-2),[],1);
X(:,4) = reshape(p2(3:M,3:N),[],1);
%axial
X(:,5) = reshape(p2(1:M-2,2:N-1),[],1);
X(:,6) = reshape(p2(2:M-1,1:N-2),[],1);
X(:,7) = reshape(p2(2:M-1,3:N),[],1);
X(:,8) = reshape(p2(3:M,2:N-1),[],1);
% X(:,9) = reshape(p2(2:M-1,2:N-1),[],1);
y = reshape(p(2:M-1,2:N-1),[],1);