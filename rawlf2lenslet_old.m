% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function lenslet_YUV = rawlf2lenslet_old(rawlf, matfilename, UpDownSampleMethod)
load(matfilename, 'DecodeOptions', 'LensletGridModel');
DecodeOptions.NWeightChans = 0;

rawlf = single(rawlf) / 255;
rawlf = LFColourCorrectInverse(rawlf, DecodeOptions.ColourMatrix, 1/2.2);
lenslet_YUV = myslicingInverse_old(rawlf, LensletGridModel, DecodeOptions);
lenslet_YUV = mytransInverse(lenslet_YUV, LensletGridModel, DecodeOptions, 'bicubic');
lenslet_YUV = uint8(round(lenslet_YUV * 255));
lenslet_YUV = rgb2ycbcr(lenslet_YUV);
lenslet_YUV = mydownsample(lenslet_YUV, UpDownSampleMethod);
