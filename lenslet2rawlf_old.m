% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function rawlf = lenslet2rawlf_old(Y, U, V, matfilename, UpDownSampleMethod)
load(matfilename, 'DecodeOptions', 'LensletGridModel');
DecodeOptions.NWeightChans = 0;

LensletImage = myupsample({Y, U, V}, UpDownSampleMethod);
LensletImage = ycbcr2rgb(LensletImage);
LensletImage = single(LensletImage) / 255;
[LensletImage, DecodeOptions, NewLensletGridModel] = mytrans(LensletImage, LensletGridModel, DecodeOptions, 'bicubic');
rawlf = myslicing_old(NewLensletGridModel, LensletImage, DecodeOptions);
rawlf = LFColourCorrect(rawlf, DecodeOptions.ColourMatrix, [1,1,1], 1/2.2);
rawlf = uint8(round(rawlf * 255));
