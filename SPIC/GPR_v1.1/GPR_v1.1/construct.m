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
function I = construct(h2, h0)

I = h2;
im = h0;
im = rgb2ntsc(im);
layer2 = imresize(im(:,:,2),size(I),'bicubic');
layer3 = imresize(im(:,:,3),size(I),'bicubic');
hi2(:,:,1) = I;
[m n] = size(I);
hi2(:,:,2) = layer2(1:m,1:n);
hi2(:,:,3) = layer3(1:m,1:n);
I = ntsc2rgb(hi2);
figure,imshow(I)






