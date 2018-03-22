% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function encoder(img_idx, rate_idx)
% The final encoder
% Input: img_idx, range in 1:12, refers to the index of test image
% Input: rate_idx, range in 1:4, refers to the required rate point
% Output: no matlab output, the bin file will be put into .\results
% Note:
% The image such as I01*.yuv must exist in .\Lenslet_YUV folder
% The related mat file such as I01*_dec.mat must exist in
% .\References_MAT folder

% Constants
lenslet_width = 7728; lenslet_height = 5368;
rawlf_yuv_width = 544; rawlf_yuv_height = 440; rawlf_frames = 13*13-4;
QP_table = [
    9,12,16,20 
    11,15,18,22
    11,14,17,22
    9,13,16,19 
    11,14,17,20
    6,8,11,14  
    8,12,15,19 
    6,9,12,16  
    10,13,17,21
    7,11,13,17 
    10,14,17,20
    9,13,17,21 
    ];
intra_qp_delta = 0; % Intra frame QP is QP_table-intra_qp_delta

% Check image
imgfn_pattern = sprintf('.\\Lenslet_YUV\\I%02d*.yuv', img_idx);
imfinfo = dir(imgfn_pattern);
assert(~isempty(imfinfo), 'The image cannot be found');
img_basename = imfinfo.name(1:end-4);
imgfn = ['.\Lenslet_YUV\', img_basename, '.yuv'];
matfn = ['.\References_MAT\', img_basename, '_dec.mat'];
assert(~isempty(dir(matfn)), 'The mat file cannot be found');

% Check rate
assert(rate_idx >= 1 && rate_idx <= 4, 'The rate point is not available');

% Make folder if not exist
if isempty(dir('.\internal'))
    mkdir('.', 'internal');
end
if isempty(dir('.\results'))
    mkdir('.', 'results');
end

% Generate filenames
rawlfyuvfn = ['.\internal\', img_basename(1:3), '_rawLF.yuv'];
binfn = ['.\results\',img_basename(1:3), 'R', num2str(rate_idx), '.bin'];
reconfn = ['.\internal\',img_basename(1:3), 'R', num2str(rate_idx), '.yuv'];

if isempty(dir(rawlfyuvfn))
    % Read YUV
    fp = fopen(imgfn, 'rb');
    [Y, U, V] = readyuv(fp, lenslet_width, lenslet_height);
    fclose(fp);
    
    % Convert Lenslet to raw views
    rawLF = lenslet2rawlf_old(Y, U, V, matfn, 'bicubic');
    writerawlfyuv(rawLF, rawlfyuvfn);
end

% Compress the raw views
command = hevc_enc({'encoder_jvet10.cfg', 'config_ra.cfg'}, rawlfyuvfn, rawlf_yuv_width, rawlf_yuv_height, rawlf_frames, QP_table(img_idx, rate_idx)-intra_qp_delta, binfn, reconfn);
disp('JEM encoder is to run, can be very slow, be patient ...');
system(command);
