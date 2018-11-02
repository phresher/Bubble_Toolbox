function imProcess(path, writeFlag)
%
mkdir([path 'output\']);
mkdir([path 'graph\']);
picListing = dir([path '0001*.tif']);
[nPic, ~] = size(picListing);
[filter, ~] = imread([path 'filter.tif']);
filter = rgb2gray(filter);
filter = imbinarize(filter);
imwrite(filter, [path 'graph\filter.png']);
sum_BW = zeros(nPic,1);
for iPic = 1:nPic
    % reading.
    [img, ~] = imread([path picListing(iPic).name]);
    %         img = imcrop(img, [42 12 299 299]);
    % converting.
    gray = rgb2gray(img);
    BW = imbinarize(gray, 'global');
    imwrite(BW, sprintf('%s%03d%s.png', [path 'graph\'], iPic, 'binarize'));
    BW = ~BW - ~filter;
    imwrite(BW, sprintf('%s%03d%s.png', [path 'graph\'], iPic, 'minus'));
    % BW(BW<0) = 0;
    % filtering
    BW = medfilt2(BW, [3 3]);
    imwrite(BW, sprintf('%s%03d%s.png', [path 'graph\'], iPic, 'med'));
    BW = imdilate(BW,strel('disk',10));
    BW = bwmorph(BW,'thin',10);
    BW = medfilt2(BW, [3 3]);
    imwrite(BW, sprintf('%s%03d%s.png', [path 'graph\'], iPic, 'smooth'));    
    BW = imfill(BW, 'holes');
    % calculating and writing
    imwrite(BW, sprintf('%s%03d%s.png', [path 'graph\'], iPic, 'final'));
    sum_BW(iPic) = sum(sum(BW));
end
radiusTimehistory = sqrt(sum_BW/pi);
radiusTimehistory(1) = 0;
if writeFlag
    xlswrite([path 'output\' 'radiusTimehistory'], radiusTimehistory);
end
