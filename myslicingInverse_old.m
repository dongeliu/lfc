% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function LensletImageRectify = myslicingInverse_old(LFSlice, LensletGridModel, DecodeOptions)
% convert LF data structure to Lenslet image .

% fprintf('\n  INVERSE:  slicing, from LF to lenslet.... \n')

% refine LensletGridModel
InputSpacing = [LensletGridModel.HSpacing, LensletGridModel.VSpacing];
NewLensletSpacing = ceil(InputSpacing);       
NewLensletSpacing = ceil(NewLensletSpacing/2)*2; % Force even so hex shift is a whole pixel multiple
XformScale = NewLensletSpacing./InputSpacing; % Notice the resized image will not be square

LensletGridModel.HSpacing = NewLensletSpacing(1);
LensletGridModel.VSpacing   = NewLensletSpacing(2);

DecodeOptions.OutputScale(1:2) = XformScale;
DecodeOptions.OutputScale(3:4) = [1, 2/sqrt(3)]; % hex sampling

NewOffset = [LensletGridModel.HOffset, LensletGridModel.VOffset].*XformScale;
RoundedOffset = round(NewOffset);  
LensletGridModel.HOffset = RoundedOffset(1);
LensletGridModel.VOffset = RoundedOffset(2);


%
USize = LensletGridModel.UMax;
VSize = LensletGridModel.VMax;
MaxSpacing = max(LensletGridModel.HSpacing, LensletGridModel.VSpacing); % enforce square on s,t
SSize = MaxSpacing + 1 ; % force odd for centered middle pixel -- H, VSpacing are even, so +1 is odd;
TSize = MaxSpacing +1 ;

% LF = zeros(TSize, SSize, VSize, USize, DecodeOptions.NColChans + DecodeOptions.NWeightChans, DecodeOptions.Precision);
OldSize = [5368, 7728]; % or load white image
NewSize = OldSize.* DecodeOptions.OutputScale(2:-1:1);
LensletImageRectify = zeros( [ceil(NewSize), 3], DecodeOptions.Precision);

TVec = cast(floor((-(TSize-1)/2) : ((TSize-1)/2)), 'int16');  % make center to 0. 
SVec = cast(floor((-(SSize-1)/2) : ((SSize-1)/2)), 'int16');

VVec = cast(0:VSize-1, 'int16');
UBlkSize = 32;

for UStart = 0 : UBlkSize : USize-1
    UStop = UStart + UBlkSize -1;
    UStop = min(UStop, USize-1);
    UVec = cast(UStart : UStop, 'int16');
    
    [tt, ss, vv, uu] = ndgrid(TVec, SVec, VVec, UVec); 
    
    %---- Build indices of 2D lenslet image-----(Each Lenslet Center) uu_th * HSpacing  + 
    %    ss (-8...0....8) (Pixel shift behind each lenslet)  + HOffset 
    LFSliceIdxX = LensletGridModel.HOffset + uu.*LensletGridModel.HSpacing + ss;
    LFSliceIdxY = LensletGridModel.VOffset + vv.*LensletGridModel.VSpacing + tt;    
    % do dehex
    HexShiftStart = LensletGridModel.FirstPosShiftRow;
    LFSliceIdxX(:,:,HexShiftStart:2:end,:) = LFSliceIdxX(:,:,HexShiftStart:2:end,:) + LensletGridModel.HSpacing/2;
    
    %---Lenslet mask in s,t and clip at image edges, ignore the pixel
    %outside the circle behind each lenslet. Restricted with HSpacing
    CurSTAspect = DecodeOptions.OutputScale(1)/DecodeOptions.OutputScale(2);
    R = sqrt((cast(tt, DecodeOptions.Precision)*CurSTAspect ).^2 + cast(ss, DecodeOptions.Precision).^2); 
    ValidIdx = find(R<LensletGridModel.HSpacing/2 & ...
        LFSliceIdxX >= 1 & LFSliceIdxY >= 1 & LFSliceIdxX <= size(LensletImageRectify, 2) & LFSliceIdxY <= size(LensletImageRectify,1) );
    
    %---clip--- the interp'd values get ignored via ValidIdx
    LFSliceIdxX = max(1, min(size(LensletImageRectify, 2), LFSliceIdxX ));
    LFSliceIdxY = max(1, min(size(LensletImageRectify, 1) , LFSliceIdxY ));
    
    %---- LensletImage index
    LFSliceIdx = sub2ind(size(LensletImageRectify), cast(LFSliceIdxY, 'int32'), ...
        cast(LFSliceIdxX, 'int32'), ones(size(LFSliceIdxX), 'int32'));
    
    % --- find corresponding LF image coordinates--- build LF image index
    tt =  tt-min(tt(:)) + 1;   % view index, from -8...0...8 to 1...9...17
    ss = ss - min(ss(:)) + 1; 
    
    vv = vv-min(vv(:)) +1; % spatial index of each view image, from 0...433 to 1...434
    uu = uu - min(uu(:)) +1 + UStart;
    
    LFOutSliceIdx = sub2ind(size(LFSlice), cast(tt,'int32'), cast(ss, 'int32'), ...
        cast(vv, 'int32'), cast(uu, 'int32'), ones(size(ss), 'int32')); 
    % RGB 
    for ColChan = 1 : DecodeOptions.NColChans
      LensletImageRectify( LFSliceIdx(ValidIdx) + numel( LensletImageRectify(: , : , 1) ).*(ColChan-1))= ...
            LFSlice(LFOutSliceIdx(ValidIdx)+ numel(LFSlice(:,:,:,:,1)) .*(ColChan-1));
        
    end
%     fprintf('%0.1f%%;   ', UStart/USize * 100);

end
%     fprintf('\n');

