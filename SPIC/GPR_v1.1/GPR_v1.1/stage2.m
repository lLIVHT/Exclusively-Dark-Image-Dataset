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
function h2 = stage2(h1, h0, scale,f)

fprintf('Stage 2 ...');
I = h0;

image = rgb2ntsc(I);
x = image(:,:,1);

x3 = h1;

% downsample result of stage 1
x2 = imresize(h1,size(x),'bicubic'); 

% if necessary, can further blur it
% but too much blur may cause artifacts in the result
 %f = fspecial('Gaussian',5,1);
 x2 = imfilter(x2,f);
% 
%  x2 = imfilter(x,f);
 
% x2(1,:) = x(1,:);
% x2(:,1) = x(:,1);
% x2(end,:) = x(end,:);
% x2(:,end) = x(:,end);
% x2(1,:,:)=x2(2,:,:);x2(:,1,:)=x2(:,2,:);
% x2(end,:,:)=x2(end-1,:,:);x2(:,end,:)=x2(:,end-1,:);

% x2(1:2,:)=x2(3:4,:);x2(:,1:2)=x2(:,3:4);
% x2(end-1:end,:)=x2(end-3:end-2,:);x2(:,end-1:end)=x2(:,end-3:end-2);

%****************************
% It is important to check that the blurred and clear image
% are properly aligned, which should be the case unless the
% patch size is odd or previous result is not aligned
%****************************
% figure,imshow(x)
% figure,imshow(x2)

% scale = 2;
sl = 20;  % low res
sh = 40;  % high res

[hh ww] = size(x3);
h = round(hh/(sh*1/3)); w=round(ww/(sh*1/3));

center = getCenter(x3,sh,h,w);
nPatch = size(center,1);
Patch_mat = cell(nPatch,3);
fprintf('patches: %d %d %d\n',h,w,nPatch);

% GPR
hyp.mean = [];
meanfunc = @meanAvg;
covfunc = @covSEiso;
likfunc = @likGauss;

for i = 1:nPatch
    if mod(i,10)==0
        fprintf('%d ',i);
    end
    if mod(i,100)==0
        fprintf('\n');
    end

    c0 = center(i,:); % highres center
    [temp rv cv] = getPatch(x3,sh,c0(1),c0(2)); % pseudo high
    Patch_mat{i,1} = rv;
    Patch_mat{i,2} = cv;

    c = round(c0/scale); % lowres center
    cr = c(1); cl = c(2);
    p = getPatch(x,sl,cr,cl);    % training patch
    p2 = getPatch(x2,sl,cr,cl);    % training patch

    % the center pixel is also included, but may be omitted
    [X9 y9] = getSet(p2,p2);
    [X y] = getSet(p2,p);  % training set
    X = [X y9];

    [Xs ys] = getSet(temp,temp); % testing set
    Xs = [Xs ys];

    n = 100;
    if length(y) < n
        idx = [1:length(y)];
    else
        [m n] = size(p);
        sr = round(linspace(1,m-2,10));
        sc = round(linspace(1,n-2,10));
        idxr = repmat(sr',1,10); idxr = idxr(:);
        idxc = repmat(sc,10,1); idxc = idxc(:);
        idx = sub2ind([m-2 n-2],idxr,idxc);
    end

    % initialize para
    cov = [-1.5; log(std(p(:)))]; lik = -3;
    hyp.cov = cov;
    hyp.lik = lik;

    [hyp] = minimize(hyp, @gp, -100, @infExact, meanfunc,covfunc, likfunc, X(idx,:), y(idx));

    [M N] = size(temp);
    bicu = reshape(temp(2:end-1,2:end-1),[],1);
    [fail ymu] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, X, y, Xs);

    if fail==0 && length(ymu)~=1 && ~isinf(hyp.cov(1)) && ~isinf(hyp.cov(1)) && ~isinf(hyp.lik)
        temp(2:end-1,2:end-1) = reshape(ymu,M-2,N-2);
% temp(3:end-2,3:end-2) = reshape(ymu,M-4,N-4);
    else
        %fprintf('fail %d\n',i);
    end
    Patch_mat{i,3} = temp;
end

fprintf('\n');

I = zeros(size(x3));
I = constructPatch3(I,Patch_mat,h,w);
%figure,imshow(I)

h2 = I;

