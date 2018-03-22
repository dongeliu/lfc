% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function LF = LFColourCorrectInverse(LF, ColMatrix, Gamma)
% assume ColBalance is all 1
LF = LF .^ (1/Gamma);
LFSize = size(LF);
NDims = numel(LFSize);
LF = reshape(LF, [prod(LFSize(1:NDims-1)), 3]);
LF = LF * inv(ColMatrix);
LF = reshape(LF, [LFSize(1:NDims-1),3]);
