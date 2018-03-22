% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function writerawlfyuv(LF, yuv_filename)
fp = fopen(yuv_filename, 'wb');
if fp < 0
    error(['Cannot open ',yuv_filename,' to write']);
end
% first the middle-middle frame as intra frame
umid = ceil(size(LF,1)/2);
vmid = ceil(size(LF,2)/2);
view = squeeze(LF(umid,vmid,:,:,1:3));
convwrite(fp, view);
for u = 3:size(LF,1)-2
    for v = 3:size(LF,2)-2
        if u == umid && v == vmid
            continue;
        end
        if (u==3 || u==size(LF,1)-2) && (v==3 || v==size(LF,2)-2)
            continue;
        end
        view = squeeze(LF(u,v,:,:,1:3));
        convwrite(fp, view);
    end
end
fclose(fp);

function convwrite(fp, view)
view_yuv = rgb2ycbcr(view);
view_yuv = extendyuv(view_yuv);
view_yuv = downsample(view_yuv);
writeyuv(fp, view_yuv{1}, view_yuv{2}, view_yuv{3});

function extended = extendyuv(input, min_block_size)
if nargin < 2
    min_block_size = 8;
end
orig_height = size(input, 1); orig_width = size(input, 2);
ext_height = ceil(orig_height / min_block_size) * min_block_size;
ext_width = ceil(orig_width / min_block_size) * min_block_size;
extended = input;
if ext_width > orig_width
    last_col = extended(:,end,:);
    extended = [extended, repmat(last_col, 1, (ext_width - orig_width), 1)];
end
if ext_height > orig_height
    last_row = extended(end,:,:);
    extended = [extended; repmat(last_row, (ext_height - orig_height), 1, 1)];
end
