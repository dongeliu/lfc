% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function qualeval(img_idx, rate_idx)
% The final quality evaluation
% Input: img_idx, range in 1:12, refers to the index of test image
% Input: rate_idx, range in 1:4, refers to the required rate point
% Output: will display bytes and PSNR_YUV_mean, the mat of PSNR will be put into .\results
% Note:
% The bitstream such as I01R1.bin must exist in .\results folder
% The decoded yuv such as I01R1_dec.yuv must exist in .\results folder
% The related mat file such as I01*_dec.mat must exist in
% .\References_MAT folder

% Constants
lenslet_width = 7728; lenslet_height = 5368;

matfn_pattern = sprintf('.\\References_MAT\\I%02d*_dec.mat', img_idx);
matfileinfo = dir(matfn_pattern);
assert(~isempty(matfileinfo), 'The mat file cannot be found');
matfn = ['.\References_MAT\', matfileinfo.name];

load(matfn, 'LF');
binfn = sprintf('.\\results\\I%02dR%1d.bin', img_idx, rate_idx);
binfileinfo = dir(binfn);
assert(~isempty(binfileinfo), 'The bitstream cannot be found');
decfn = sprintf('.\\results\\I%02dR%1d_dec.yuv', img_idx, rate_idx);
assert(~isempty(dir(decfn)), 'The decoded yuv cannot be found');
psnrmatfn = ['.\results\',matfileinfo.name(1:3),'R',num2str(rate_idx),'_PSNR.mat'];
fp = fopen(decfn, 'rb');
[Y, U, V] = readyuv(fp, lenslet_width, lenslet_height);
fclose(fp);
decLF = DecodeLenslet(Y, U, V, matfn);
decLF = uint8(round(decLF * 255));
[PSNR_Y, PSNR_U, PSNR_V, PSNR_YUV, PSNR_Y_mean, PSNR_U_mean, PSNR_V_mean, PSNR_YUV_mean] = ComputePSNR(LF, decLF);
disp([num2str(binfileinfo.bytes), ' ', num2str(PSNR_YUV_mean)]);
save(psnrmatfn, 'PSNR_Y', 'PSNR_U', 'PSNR_V', 'PSNR_YUV', 'PSNR_Y_mean', 'PSNR_U_mean', 'PSNR_V_mean', 'PSNR_YUV_mean');
