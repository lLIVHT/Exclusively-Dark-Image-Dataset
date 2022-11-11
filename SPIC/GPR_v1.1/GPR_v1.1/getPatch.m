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
function [patch, rv, cv] = getPatch(I, s, cr, cc)
%function [patches patches_mat pm_zero] = getPatch(I, s, d)
% I: image
% l: size of the patch (squre)
% t: distance between patches

[h w] = size(I);

r = round(cr-s/2);
c = round(cc-s/2);
rv = (max(1,r)):(min(h,r+s-1));
cv = (max(1,c)):(min(w,c+s-1));
patch = I(rv,cv);
% rv = rv(3:end-2);
% cv = cv(3:end-2);