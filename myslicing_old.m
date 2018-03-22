% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function LF = myslicing_old(NewLensletGridModel, LensletImageRectify, DecodeOptions)
% convert lenslet image to raw LF data
% fprintf('\n Slicing lenslet into LF....\n')

USize = NewLensletGridModel.UMax;
VSize = NewLensletGridModel.VMax;
MaxSpacing = max(NewLensletGridModel.HSpacing, NewLensletGridModel.VSpacing); % enforce square on s,t
SSize = MaxSpacing + 1 ; % force odd for centered middle pixel -- H, VSpacing are even, so +1 is odd;
TSize = MaxSpacing +1 ;

LF = zeros(TSize, SSize, VSize, USize, DecodeOptions.NColChans + DecodeOptions.NWeightChans, DecodeOptions.Precision);

TVec = cast(floor((-(TSize-1)/2) : ((TSize-1)/2)), 'int16');  % view offset relative the lenslet center. 
SVec = cast(floor((-(SSize-1)/2) : ((SSize-1)/2)), 'int16');

VVec = cast(0:VSize-1, 'int16'); % index of each lenlet array center, begin with 0;
UBlkSize = 32;

for UStart = 0 : UBlkSize : USize-1
    UStop = UStart + UBlkSize -1;
    UStop = min(UStop, USize-1);
    UVec = cast(UStart : UStop, 'int16'); % index of each lenlet array center, begin with 0;
    
    [tt, ss, vv, uu] = ndgrid(TVec, SVec, VVec, UVec); 
    
    %---- Build pixel indices of 2D lenslet image-----(Each Lenslet Center) uu_th * HSpacing  + 
    %    ss (-8...0....8) (Pixel shift behind each lenslet)  + HOffset (first lenslet center offset)
    LFSliceIdxX = NewLensletGridModel.HOffset + uu.*NewLensletGridModel.HSpacing + ss;
    LFSliceIdxY = NewLensletGridModel.VOffset + vv.*NewLensletGridModel.VSpacing + tt;    
    % do dehex. the x index will rightwards shift due to lenslet array hex sampling.
    HexShiftStart = NewLensletGridModel.FirstPosShiftRow;
    LFSliceIdxX(:,:,HexShiftStart:2:end,:) = LFSliceIdxX(:,:,HexShiftStart:2:end,:) + NewLensletGridModel.HSpacing/2;
    
    %---Lenslet mask in s,t and clip at image edges, ignore the pixel
    %outside the circle behind each lenslet. Restricted with HSpacing
    CurSTAspect = DecodeOptions.OutputScale(1)/DecodeOptions.OutputScale(2);
    R = sqrt((cast(tt, DecodeOptions.Precision)*CurSTAspect ).^2 + cast(ss, DecodeOptions.Precision).^2); 
    ValidIdx = find(R<NewLensletGridModel.HSpacing/2 & ...
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
    
    LFOutSliceIdx = sub2ind(size(LF), cast(tt,'int32'), cast(ss, 'int32'), ...
        cast(vv, 'int32'), cast(uu, 'int32'), ones(size(ss), 'int32')); 
    % RGB 
    for ColChan = 1 : DecodeOptions.NColChans
        LF(LFOutSliceIdx(ValidIdx)+ numel(LF(:,:,:,:,1)) .*(ColChan-1)) = ...
            LensletImageRectify( LFSliceIdx(ValidIdx) + numel( LensletImageRectify(: , : , 1) ).*(ColChan-1));       
    end
%     fprintf('%0.1f%%;   ', UStart/USize * 100);
end

%     fprintf('\n  ');







