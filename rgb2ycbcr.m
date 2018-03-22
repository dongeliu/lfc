% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script for RGB 444 to YCbCr 444 color space conversion
% Input: RGB image in uint8 representation [0-255]

% Output: YCbCr image in uint8 representation [0-255]

function [ycbcr] = rgb2ycbcr(rgb)

M = [    0.212600  0.715200  0.072200 ;
        -0.114572 -0.385428  0.500000 ;
         0.500000 -0.454153 -0.045847   ];

ycbcr = reshape(double(rgb)/255, [], 3) * M';
ycbcr = reshape(ycbcr, size(rgb));
ycbcr(:,:,1) = 219*ycbcr(:,:,1) + 16;
ycbcr(:,:,2:3) = 224*ycbcr(:,:,2:3) + 128;
ycbcr = uint8(ycbcr);
