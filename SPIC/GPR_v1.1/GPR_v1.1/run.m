% Module Leader:	Prof. W.C. Siu, PhD, CEng, FIEE, FHKIE, FIEEE, Chair Professor
% Student:	Ms. He He, BEng (Hons)
%
% Version 1.1 (More obvious deblurring performence)
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

%function run(imagePath)
imagePath = './testImage/bb.png';    %input image name
startup
h0 = imread(imagePath);
% h0 = h0(50:100,50:100,:);

fprintf('This Matlab code is not optimized, the process may take long time (more than an hour) ...\n');

SRfactor=3;                          % magnification factor
h1 = stage1(h0, SRfactor);           % interpolation result
figure,imshow(h1)
title('Stage 1 result')
f = fspecial('Gaussian',SRfactor,1);  % point spread function for de-blurring
h2 = stage2(h1, h0, SRfactor, f);       % deblurring result
figure,imshow(h2)
title('Stage 2 result')
I = construct(h2, h0);
imwrite( I,'SR_result_bb.png');        % final result
bic = imresize(h0,SRfactor,'bicubic');      % bicubic interpolation
imwrite( bic,'Bicubic_result_bb.png');
%figure,imshow(h1)
%figure,imshow(h2)
subplot(1,3,1)
imshow(h0)
title('Low Resolution Input');
subplot(1,3,2)
imshow(I)
title('Super-resolution Result');
subplot(1,3,3)
imshow(bic)
title('Bicubic Interpolation');