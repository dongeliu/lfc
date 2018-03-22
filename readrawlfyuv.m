% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function LF = readrawlfyuv(yuv_filename, yuv_width, yuv_height, rawlf_size)
fp = fopen(yuv_filename, 'rb');
if fp < 0
    error(['Cannot open ',yuv_filename,' to read']);
end
LF = zeros(rawlf_size, 'uint8');
rawlf_height = rawlf_size(3);
rawlf_width = rawlf_size(4);
umid = ceil(size(LF,1)/2);
vmid = ceil(size(LF,2)/2);
LF(umid,vmid,:,:,1:3) = readconv(fp, yuv_width, yuv_height, rawlf_width, rawlf_height);
for u = 3:size(LF,1)-2
    for v = 3:size(LF,2)-2
        if u == umid && v == vmid
            continue;
        end
        if (u==3 || u==size(LF,1)-2) && (v==3 || v==size(LF,2)-2)
            continue;
        end
        LF(u,v,:,:,1:3) = readconv(fp, yuv_width, yuv_height, rawlf_width, rawlf_height);
    end
end
fclose(fp);
LF(3:size(LF,1)-2,1,:,:,:) = LF(3:size(LF,1)-2,3,:,:,:);
LF(3:size(LF,1)-2,2,:,:,:) = LF(3:size(LF,1)-2,3,:,:,:);
LF(3:size(LF,1)-2,size(LF,2)-1,:,:,:) = LF(3:size(LF,1)-2,size(LF,2)-2,:,:,:);
LF(3:size(LF,1)-2,size(LF,2),:,:,:) = LF(3:size(LF,1)-2,size(LF,2)-2,:,:,:);
LF(1,:,:,:,:) = LF(3,:,:,:,:);
LF(2,:,:,:,:) = LF(3,:,:,:,:);
LF(size(LF,1)-1,:,:,:,:) = LF(size(LF,1)-2,:,:,:,:);
LF(size(LF,1),:,:,:,:) = LF(size(LF,1)-2,:,:,:,:);

function view = readconv(fp, yuv_width, yuv_height, clip_width, clip_height)
[Y, U, V] = readyuv(fp, yuv_width, yuv_height);
view_yuv = upsample({Y, U, V});
view_yuv = view_yuv(1:clip_height, 1:clip_width, :);
view = ycbcr2rgb(view_yuv);
