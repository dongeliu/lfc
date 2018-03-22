% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function LensletImage_YUV_444 = myupsample(LensletImage_YUV_420, method)

LensletImage_YUV_444(:, :, 1) = LensletImage_YUV_420{1};
for i = 2: 3
    LensletImage_YUV_444(:, :,  i) = imresize(LensletImage_YUV_420{ i}, 2, method);
end

