% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function BackLensletImage_YUV_420 = mydownsample(BackLensletImage_YUV_444, method)

BackLensletImage_YUV_420{1} = BackLensletImage_YUV_444(:, :, 1);
BackLensletImage_YUV_420{2} = imresize( BackLensletImage_YUV_444(:, :, 2), 0.5, method);
BackLensletImage_YUV_420{3} = imresize( BackLensletImage_YUV_444(:, :, 3), 0.5, method);