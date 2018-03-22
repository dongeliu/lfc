% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script performing 444 to 420 downsampling

% Input: image in YCbCr 444 sampling 8 bits in uint8 representation [0-255]

% Output: 3x1 cell, each cell item contatin one channel Y,Cb, Cr
% coresponding to 420 solor sampling

function [out] = downsample(in)

out = cell(3,1);
for i=1:3
    out{i} = in(:,:,i);
end

for i=2:3
    tmp = imfilter(double(out{i}), [1 6 1], 'replicate', 'same');
    out{i} = tmp(:,1:2:end);
end

for i=2:3
    tmp = imfilter(out{i}, [0 ; 4 ; 4], 'replicate', 'same');
    out{i} = uint8((tmp(1:2:end,:) + 32) / 64);
end
