% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script for YCbCr 444 to RGB 444 color space conversion
% Input: YCbCr image in uint8 representation [0-255]

% Output:RGB image in uint8 representation [0-255]

function [rgb] = ycbcr2rgb(ycbcr)

ycbcr = double(ycbcr);
ycbcr(:,:,1) = clip((ycbcr(:,:,1) - 16) / 219, 0, 1);
ycbcr(:,:,2:3) = clip((ycbcr(:,:,2:3) - 128) / 224, -0.5, 0.5);

M = [   1  0        1.57480 ;
        1 -0.18733 -0.46813 ;
        1  1.85563  0           ];

rgb = reshape(ycbcr, [], 3) * M';
rgb = reshape(rgb, size(ycbcr));
rgb = uint8(255 * rgb);
end

function [out] = clip(in, min, max)
    out = in;
    out(in < min) = min;
    out(in > max) = max;
end