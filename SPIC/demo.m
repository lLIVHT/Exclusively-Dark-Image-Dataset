% GP enhancement demo

cnn_model = '.\cnnmodel.mat';                                % pretrained CNN model
image_name = 'D:\File\lowlight\image\10.bmp';

load(cnn_model);                                             % load CNN model
image = imread(image_name);

gp_res = gp_en(image,net);                                   % enhancement function

 figure
% subplot(1,2,1)
% imshow(image)
% subplot(1,2,2)
imshow(gp_res)
