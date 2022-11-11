image_name = 'D:/File/lowlight/image/06.jpg';
rimage_name = 'D:/File/lowlight/image/engan06.jpeg';
rimage = imread(rimage_name);
image = imread(image_name);
%% 原图的hsv
% 
% imageh=rgb2hsv(image);
% figure
% subplot(2,2,1)
% imshow(image)
% subplot(2,2,2)
% %亮度
% imshow(imageh(:,:,3))
% subplot(2,2,3)
% %色调
% imshow(imageh(:,:,1))
% subplot(2,2,4)
% %饱和度
% imshow(imageh(:,:,2))
% 
% %% 修复图的hsv
% 
% rimageh=rgb2hsv(rimage);
% figure
% subplot(2,2,1)
% imshow(rimage)
% subplot(2,2,2)
% %亮度
% imshow(rimageh(:,:,3))
% subplot(2,2,3)
% %色调
% imshow(rimageh(:,:,1))
% subplot(2,2,4)
% %饱和度
% imshow(rimageh(:,:,2))

% %% 修复图的lab
% rimagelab=rgb2lab(image);
% figure
% subplot(2,2,1)
% imshow(rimagelab)
% subplot(2,2,2)
% %亮度
% imshow(rimagelab(:,:,1))
% subplot(2,2,3)
% %色调
% imshow(rimagelab(:,:,2))
% subplot(2,2,4)
% %饱和度
% imshow(rimagelab(:,:,3))

%% ycbcr
%  
% imagecbcr=rgb2ycbcr(image);
% figure
% subplot(2,2,1)
% imshow(imagecbcr)
% subplot(2,2,2)
% %亮度
% imshow(imagecbcr(:,:,1))
% subplot(2,2,3)
% %色调
% imshow(imagecbcr(:,:,2))
% subplot(2,2,4)
% %饱和度
% imshow(imagecbcr(:,:,3))
% 
% rimagecbcr=rgb2ycbcr(rimage);
% figure
% subplot(2,2,1)
% imshow(rimagecbcr)
% subplot(2,2,2)
% %亮度
% imshow(rimagecbcr(:,:,1))
% subplot(2,2,3)
% %色调
% imshow(rimagecbcr(:,:,2))
% subplot(2,2,4)
% %饱和度
% imshow(rimagecbcr(:,:,3))

%% fft
imagecbcr=rgb2ycbcr(image);
rimagecbcr=rgb2ycbcr(rimage);
fftimge=fft2(imagecbcr(:,:,1));
fftrimge=fft2(rimagecbcr(:,:,1));
figure                       
mesh(abs(fftimge))
figure                       
mesh(abs(fftrimge))





