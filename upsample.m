% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script performing 420 to 444 upsampling

% Input: 3x1 cell, each cell item contatin one channel Y,Cb, Cr
% coresponding to 420 solor sampling

% Output: image in YCbCr 444 sampling 8 bits in uint8 representation [0-255]


function [out] = upsample(in)

out = uint8(zeros(size(in{1}, 1), size(in{1}, 2), 3));
out(:,:,1) = in{1};
tmp = cell(3,1);

for i=2:3
    even = imfilter(double(in{i}), [-2 ; 16 ; 54 ; -4 ; 0], 'replicate', 'same');
    odd = imfilter(double(in{i}), [0 ; -4 ; 54 ; 16 ; -2], 'replicate', 'same');
    fields = zeros(2*size(even,1), size(even,2));
    fields(1:2:end,:) = even;
    fields(2:2:end,:) = odd;
    tmp{i} = fields;
end

for i=2:3
    even = (tmp{i} + 32) / 64;
    odd = imfilter(tmp{i}, [0 -4 36 36 -4], 'replicate', 'same');
    odd = (odd + 2048) / 4096; % shift = 12 i.e. (2^12); offset = 2048
    fields = zeros(size(even,1), 2*size(even,2));
    fields(:,1:2:end) = even;
    fields(:,2:2:end) = odd;
    out(:,:,i) = uint8(fields);
end
