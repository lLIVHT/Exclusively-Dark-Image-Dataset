% run startup.m first in order to use the GP package

I = imread('monarch_lowres_input.jpg');

I = I(70:100,60:90,:);

% change to YIQ
image = rgb2ntsc(I);

% run algorithm on illuminance channel
x = image(:,:,1);  % first round on original LR input

% load results from previous stage
% load lenax2_deblur
% x=I;

%**********************************
% set parameters here
%**********************************
scale = 2;
% patch size
sl = 20;  % low res
sh = 40;  % high res

tic

[hh ww] = size(x);
fprintf('current size: %d %d\n',hh,ww);

% upsample the LR image
x3 = imresize(x,scale,'bicubic');

[hh ww] = size(x3);
fprintf('enlarge to: %d %d\n',hh,ww);

% 1/3 of the patch is NOT overlapped
h = round(hh/(sh*1/3)); 
w = round(ww/(sh*1/3));

center = getCenter(x3,sh,h,w);
nPatch = size(center,1);
Patch_mat = cell(nPatch,3);
fprintf('patches: %d %d %d\n',h,w,nPatch);

% GPR functions
hyp.mean = [];
meanfunc = @meanAvg;
covfunc = @covSEiso;
likfunc = @likGauss;

for i = 1:nPatch
    
    % process
    if mod(i,10)==0
        fprintf('%d ',i);
    end
    if mod(i,100)==0
        fprintf('\n');
    end

    c0 = center(i,:); % highres center
    % get patch from upsampled LR image (testing patch)
    [temp rv cv] = getPatch(x3,sh,c0(1),c0(2)); 
    % save location
    Patch_mat{i,1} = rv;
    Patch_mat{i,2} = cv;

    c = round(c0/scale); % lowres center
    cr = c(1); cl = c(2);
    % get patch from LR image (training patch)
    p = getPatch(x,sl,cr,cl);    

    % training set
    [X y] = getSet(p,p);  

    % testing set
%     [Xs ys] = getSet(temp,temp); 
    [Xs ys] = getSet(temp,temp); 

    % number of training points
    n = 100;
    if length(y) < n
        idx = [1:length(y)];
    else       
        % grid sampling
        [m n] = size(p);
        sr = round(linspace(1,m-2,10));
        sc = round(linspace(1,n-2,10));
        idxr = repmat(sr',1,10); idxr = idxr(:);
        idxc = repmat(sc,10,1); idxc = idxc(:);
        idx = sub2ind([m-2 n-2],idxr,idxc);
    end

    % initialize GPr parameter
    cov = [-1.5; log(std(p(:)))]; lik = -3;
    hyp.cov = cov;
    hyp.lik = lik;

    % MAP estimation
    [hyp] = minimize(hyp, @gp, -100, @infExact, meanfunc,covfunc, likfunc, X(idx,:), y(idx));

    [M N] = size(temp);
    
    % GPR inference
    [fail ymu] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, X, y, Xs);

    if fail==0 && length(ymu)~=1 && ~isinf(hyp.cov(1)) && ~isinf(hyp.cov(1)) && ~isinf(hyp.lik)
        temp(2:end-1,2:end-1) = reshape(ymu,M-2,N-2);
%         temp(3:end-2,3:end-2) = reshape(ymu,M-4,N-4);
    else
        fprintf('fail %d\n',i);
    end
    Patch_mat{i,3} = temp;
%     Patch_mat{i,3} = temp(3:end-2,3:end-2);
end

I = zeros(size(x3));
I = constructPatch3(I,Patch_mat,h,w);
figure,imshow(I)

toc

% compare the result and bicubic interpolation result
% sometimes there is 1 pixel deviation
% correct it here properly

% I(1:2,:) = I(3:4,:);
% I(:,1:2) = I(:,3:4);
% figure,imshow(I)

% I(end,:)=[];I(:,end)=[];
% I=[I(1,:);I]; I=[I(:,1) I];


