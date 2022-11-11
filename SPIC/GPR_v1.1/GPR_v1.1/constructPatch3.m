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

function I = constructPatch3(I, p,R, C)
% %function [patches patches_mat pm_zero] = getPatch(I, s, d)
% % I: image
% % l: size of the patch (squre)
% % t: distance between patches
% I = constructPatch(I,Patch_mat,center(:,1),center(:,2),R,C);
% p = Patch_mat;
% cr = center(:,1);cc = center(:,2);H=R;W=C;
% 
I = zeros(size(I));
ii = 1;
[h w] = size(I);
for row = 1:R
    rowv = p{ii,1};
    temp = zeros(length(rowv),w);
    for col = 1:C
        colv = p{ii,2};
        patch = p{ii,3};
        if col ~= 1
            olc = intersect(colv,last_cv);
            a = linspace(0,1,length(olc));
            W = repmat(a,size(temp,1),1);           
            patch(:,1:length(olc)) = patch(:,1:length(olc)).*W;           
            temp(:,olc) = temp(:,olc).*(1-W);
            temp(:,colv) = temp(:,colv)+patch;
        else
            temp(:,colv) = temp(:,colv) + patch;
        end
%         imshow(temp);
        last_cv = 1:colv(end);
        ii = ii+1;
    end    
    if row ~= 1
        olr = intersect(rowv,last_rv);
        a = linspace(0,1,length(olr));
        W = repmat(a',1,size(temp,2));
        I(olr,:) = I(olr,:).*(1-W);
        temp(1:length(olr),:) = temp(1:length(olr),:).*W;
        I(rowv,:) = I(rowv,:)+temp;
    else
        I(rowv,:) = I(rowv,:) + temp(:,:);
    end
    last_rv = 1:rowv(end);
end

% I(1,:) = I(2,:);
% I(:,1) = I(:,2);
        

