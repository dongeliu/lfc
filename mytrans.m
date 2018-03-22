% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function [LensletImageRectify,  DecodeOptions, NewLensletGridModel] = ...
    mytrans(LensletImage, LensletGridModel,  DecodeOptions, tform_method)

% LensletImage = cast(LensletImage, DecodeOptions.Precision) ;
% fprintf('\n Rectify RGB lenslet image to correspond to the lenslet grid to discretized pixels \n')
%----- Transform to an integer-spaced grid
InputSpacing = [LensletGridModel.HSpacing, LensletGridModel.VSpacing];
NewLensletSpacing = ceil(InputSpacing);
% Force even so hex shift is a whole pixel multiple
NewLensletSpacing = ceil(NewLensletSpacing/2)*2;
XformScale = NewLensletSpacing./InputSpacing; % Notice the resized image will not be square
% non-integer correspondence to integer correspondence between ccd with lenslet array
NewOffset = [LensletGridModel.HOffset, LensletGridModel.VOffset].*XformScale;
RoundedOffset = round(NewOffset);  
XformTrans = RoundedOffset-NewOffset;

DecodeOptions.OutputScale(1:2) = XformScale;
DecodeOptions.OutputScale(3:4) = [1, 2/sqrt(3)]; % hex sampling

%-----Fix image rotation,  scale, transformation
RRot = LFRotz(LensletGridModel.Rot);
RScale = eye(3);
RScale(1,1) = XformScale(1);
RScale(2,2) = XformScale(2);

RTrans = eye(3);
RTrans(end, 1:2) = XformTrans;

% The following rotation can rotate parts of the lenslet image out of frame.
% todo[optimization]: attempt to keep these regions, offer greater user-control of what's kept

RRectify = RRot*RScale*RTrans;
FixAll = maketform('affine', RRectify);
OldSize = size(LensletImage(:,:,1));
NewSize =OldSize.*XformScale(2:-1:1);
% default is bilinear. but nearest is produce best performance than bilinear, bicubic.
LensletImageRectify = imtransform(LensletImage, FixAll, tform_method, 'YData', [1, NewSize(1)], 'XData', [1, NewSize(2)]);

% FixAllInv = maketform('affine', inv(RRectify));
% LensletImageInv= imtransform(LensletImageRectify, FixAllInv, 'YData', [1, OldSize(1)], 'XData', [1, OldSize(2)]);

%
NewLensletGridModel = struct('HSpacing', NewLensletSpacing(1), 'VSpacing', NewLensletSpacing(2), ...
    'HOffset', RoundedOffset(1), 'VOffset', RoundedOffset(2), 'Rot', 0, ...
    'UMax', LensletGridModel.UMax, 'VMax', LensletGridModel.VMax, ...
    'Orientation', LensletGridModel.Orientation, 'FirstPosShiftRow', LensletGridModel.FirstPosShiftRow);

% if(nargout>2)
%     WhiteImage = imtransform(WhiteImage, FixAll, 'YData', [1, NewSize(1)], 'XData', [1, NewSize(2)]);
% end

