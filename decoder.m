% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function decoder(img_idx, rate_idx)
% The final decoder
% Input: img_idx, range in 1:12, refers to the index of test image
% Input: rate_idx, range in 1:4, refers to the required rate point
% Output: no matlab output, the yuv file will be put into .\results
% Note:
% The bitstream such as I01R1.bin must exist in .\results folder
% The related mat file such as I01*_dec.mat must exist in
% .\05_References_MAT folder

% Constants
rawlf_yuv_width = 544; rawlf_yuv_height = 440; rawlf_frames = 13*13-4;
rawlf_width = 541; rawlf_height = 434;

% Check bitstream
binfn = sprintf('.\\results\\I%02dR%1d.bin', img_idx, rate_idx);
assert(~isempty(dir(binfn)), 'The bitstream cannot be found');
matfn_pattern = sprintf('.\\References_MAT\\I%02d*_dec.mat', img_idx);
matfileinfo = dir(matfn_pattern);
assert(~isempty(matfileinfo), 'The mat file cannot be found');
matfn = ['.\References_MAT\', matfileinfo.name];

% Make folder if not exist
if isempty(dir('.\internal'))
    mkdir('.', 'internal');
end

% Generate filenames
rawlf_reconyuvfn = ['.\internal\', matfileinfo.name(1:3), 'R',num2str(rate_idx),'_rawLFrecon.yuv'];
decfn = ['.\results\',matfileinfo.name(1:3), 'R', num2str(rate_idx), '_dec.yuv'];

command = hevc_dec(binfn, rawlf_reconyuvfn);
[status, cmdout] = system(command);
assert(status == 0 && length(strfind(cmdout, 'OK')) == rawlf_frames, 'Decoding error');

rawLFrecon = readrawlfyuv(rawlf_reconyuvfn, rawlf_yuv_width, rawlf_yuv_height, [17,17,rawlf_height,rawlf_width,3]);
lensletrecon = rawlf2lenslet_old(rawLFrecon, matfn, 'bicubic');
fp = fopen(decfn, 'wb');
writeyuv(fp, lensletrecon{1}, lensletrecon{2}, lensletrecon{3});
fclose(fp);
