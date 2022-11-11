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
function [center] = getCenter(I, s, h, w)
%function [patches patches_mat pm_zero] = getPatch(I, s, d)
% I: image
% l: size of the patch (squre)
% t: distance between patches

[M N] = size(I);
idx = 1;
row = round(linspace(1,M-s+1,h));
col = round(linspace(1,N-s+1,w));
nPatch = h*w;
center = zeros(nPatch,2);
%patches = zeros(s*s, nPatch);
% patches_mat = zeros(s,s,nPatch);
%pm_zero = zeros(s,s, nPatch);
for i = row
    for j = col
        center(idx,:) = [round(i+s/2) round(j+s/2)];
%         temp = double(I(i:i+s-1, j:j+s-1));
        %patches(:,idx) = temp(:);
%         patches_mat(:,:,idx) = temp;
        %pm_zero = temp - mean(temp(:))*ones(s,s);
        idx = idx+1;
    end
end