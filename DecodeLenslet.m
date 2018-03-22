% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% This script is a modified version of function LFDecodeLensletImageSimple.m,
% which is a part of LF Toolbox v0.4 released 12-Feb-2015
%(Copyright (c) 2013-2015 Donald G. Dansereau)
% See also:  LFLytroDecodeImage, LFUtilDecodeLytroFolder

% This script was used to produce LF data structure for JPEG anchors
% corresponding to CfP document for ICME Grand Challenge. It provides LF
% datasturcture which is already color corected and gamma corrected.

% For the entire processign chain to transform Lenslet image to LF data
% structure, see the LF toolbox documentation especially functions:
% LFDecodeLensletImageSimple, LFLytroDecodeImage, LFUtilDecodeLytroFolder.

% Input: Y U and V channels as produced by my JPEG 420 8 bit coder, MAT
% file from 05_Reference_MAt folder corresponding to processed content -
% MAT file contain information about white image which should be used...

% Output: LFdecC, LFdec, LFWeight, DecodeOptions, CorrectedLensletImage
%important output for Grand Challenge is: LFdecC, which is color and gamma
%(1/2.2) corrected LF data structure.

% Please note: this function uses the LF toolbox functions, so make sure
% the LF toolbox is properly installed!


function [LFdecC, LFdec, LFWeight, DecodeOptions, CorrectedLensletImage] = ...
    DecodeLenslet( Y,U,V, MAT) %, LensletGridModel, DecodeOptions )
% takes lenslet and convert it to LF, aplies gamma and color correction
%
%init - this is to have the proper white image corresponding to the
%processed content
load(MAT) % mat file from reference folder (for example I01_Bikes_dec.mat) - it contains important info about white image for chosen content
DecodeOptions.NWeightChans = 0; % added by Dong Liu, we don't need the weight channel
% winame = ['DRIVE:\PATH\',DecodeOptions.WhiteImageInfo.Fname]; % needs to be updated to your environment
% WhiteRawFname = LFFindLytroPartnerFile(winame, DecodeOptions.WhiteRawDataFnameExtension);
% BitPacking = '10bit';
% WhiteImage = LFReadRaw( WhiteRawFname, BitPacking );

% here the lenslet image is created from Y U and V parts (my inputs)
% Otherwise, Lenslet in RGB 444 is needed
LensletImage_YUV_420{1,1} = double(Y);
LensletImage_YUV_420{2,1} = double(U);
LensletImage_YUV_420{3,1} = double(V);

LensletImage_YUV_444 = upsample(LensletImage_YUV_420);
LensletImage = ycbcr2rgb(LensletImage_YUV_444);
LensletImage = single(LensletImage)/double(intmax('uint8'));


%% this is a part of original LFDecodeLensletImageSimple.m file - good for processing original raw lenslet i.e. including demosaicing and devigneting
% note: there is no clipping here because it is assumed for the purposes of
% Grand challenge that Lenslet input is in uint8 precision

% %---Rescale image values, remove black level---
% DecodeOptions.LevelLimits = cast(DecodeOptions.LevelLimits, DecodeOptions.Precision);
% BlackLevel = DecodeOptions.LevelLimits(1);
% WhiteLevel = DecodeOptions.LevelLimits(2);
% WhiteImage = cast(WhiteImage, DecodeOptions.Precision);
% WhiteImage = (WhiteImage - BlackLevel) ./ (WhiteLevel - BlackLevel);
%
% LensletImage = cast(LensletImage, DecodeOptions.Precision);
% LensletImage = (LensletImage - BlackLevel) ./ (WhiteLevel - BlackLevel);
% LensletImage = LensletImage ./ WhiteImage; % Devignette
% % Clip -- this is aggressive and throws away bright areas; there is a potential for an HDR approach here
% LensletImage = min(1, max(0, LensletImage));
%
% if( nargout < 2 )
%     clear WhiteImage
% end

% %---Demosaic---
% % This uses Matlab's demosaic, which is "gradient compensated". This likely has implications near
% % the edges of lenslet images, where the contrast is due to vignetting / aperture shape, and is not
% % a desired part of the image
% LensletImage = cast(LensletImage.*double(intmax('uint16')), 'uint16');
% LensletImage = demosaic(LensletImage, DecodeOptions.DemosaicOrder);
% LensletImage = cast(LensletImage, DecodeOptions.Precision);
% LensletImage = LensletImage ./  double(intmax('uint16'));
% DecodeOptions.NColChans = 3;
%
% if( nargout >= 2 )
%     DecodeOptions.NWeightChans = 1;
% else
%     DecodeOptions.NWeightChans = 0;
% end
%
% if( nargout > 3 )
%     DebayerLensletImage = LensletImage;
% end

%---Tranform to an integer-spaced grid---
% fprintf('\nAligning image to lenslet array...');
InputSpacing = [LensletGridModel.HSpacing, LensletGridModel.VSpacing];
NewLensletSpacing = ceil(InputSpacing);
% Force even so hex shift is a whole pixel multiple
NewLensletSpacing = ceil(NewLensletSpacing/2)*2;
XformScale = NewLensletSpacing ./ InputSpacing;  % Notice the resized image will not be square

NewOffset = [LensletGridModel.HOffset, LensletGridModel.VOffset] .* XformScale;
RoundedOffset = round(NewOffset);
XformTrans =  RoundedOffset-NewOffset;

NewLensletGridModel = struct('HSpacing',NewLensletSpacing(1), 'VSpacing',NewLensletSpacing(2), ...
    'HOffset',RoundedOffset(1), 'VOffset',RoundedOffset(2), 'Rot',0, ...
    'UMax', LensletGridModel.UMax, 'VMax', LensletGridModel.VMax, 'Orientation', LensletGridModel.Orientation, ...
    'FirstPosShiftRow', LensletGridModel.FirstPosShiftRow);

%---Fix image rotation and scale---
RRot = LFRotz( LensletGridModel.Rot );

RScale = eye(3);
RScale(1,1) = XformScale(1);
RScale(2,2) = XformScale(2);
DecodeOptions.OutputScale(1:2) = XformScale;
DecodeOptions.OutputScale(3:4) = [1,2/sqrt(3)];  % hex sampling

RTrans = eye(3);
RTrans(end,1:2) = XformTrans;

% The following rotation can rotate parts of the lenslet image out of frame.
% todo[optimization]: attempt to keep these regions, offer greater user-control of what's kept
FixAll = maketform('affine', RRot*RScale*RTrans);
NewSize = size(LensletImage(:,:,1)) .* XformScale(2:-1:1);
LensletImage = imtransform( LensletImage, FixAll, 'YData',[1 NewSize(1)], 'XData',[1 NewSize(2)]);
% if( nargout >= 2 )
%     WhiteImage = imtransform( WhiteImage, FixAll, 'YData',[1 NewSize(1)], 'XData',[1 NewSize(2)]);
% end
if( nargout >= 4 )
    CorrectedLensletImage = LensletImage;
end

LFdec = SliceXYImage( NewLensletGridModel, LensletImage, [], DecodeOptions );
clear WhiteImage LensletImage

%---Correct for hex grid and resize to square u,v pixels---
LFSize = size(LFdec);
HexAspect = 2/sqrt(3);
switch( DecodeOptions.ResampMethod )
    case 'fast'
%         fprintf('\nResampling (1D approximation) to square u,v pixels');
        NewUVec = 0:1/HexAspect:(size(LFdec,4)+1);  % overshoot then trim
        NewUVec = NewUVec(1:ceil(LFSize(4)*HexAspect));
        OrigUSize = size(LFdec,4);
        LFSize(4) = length(NewUVec);
        %---Allocate dest and copy orig LF into it (memory saving vs. keeping both separately)---
        LF2 = zeros(LFSize, DecodeOptions.Precision);
        LF2(:,:,:,1:OrigUSize,:) = LFdec;
        LFdec = LF2;
        clear LF2
        
        if( DecodeOptions.DoDehex )
            ShiftUVec = -0.5+NewUVec;
%             fprintf(' and removing hex sampling...');
        else
            ShiftUVec = NewUVec;
%             fprintf('...');
        end
        for( ColChan = 1:size(LFdec,5) )
            CurUVec = ShiftUVec;
            for( RowIter = 1:2 )
                RowIdx = mod(NewLensletGridModel.FirstPosShiftRow + RowIter, 2) + 1;
                ShiftRows = squeeze(LFdec(:,:,RowIdx:2:end,1:OrigUSize, ColChan));
                SliceSize = size(ShiftRows);
                SliceSize(4) = length(NewUVec);
                ShiftRows = reshape(ShiftRows, [size(ShiftRows,1)*size(ShiftRows,2)*size(ShiftRows,3), size(ShiftRows,4)]);
                ShiftRows = interp1( (0:size(ShiftRows,2)-1)', ShiftRows', CurUVec' )';
                ShiftRows(isnan(ShiftRows)) = 0;
                LFdec(:,:,RowIdx:2:end,:,ColChan) = reshape(ShiftRows,SliceSize);
                CurUVec = NewUVec;
            end
        end
        clear ShiftRows
        DecodeOptions.OutputScale(3) = DecodeOptions.OutputScale(3) * HexAspect;
        
    case 'triangulation'
%         fprintf('\nResampling (triangulation) to square u,v pixels');
        OldVVec = (0:size(LFdec,3)-1);
        OldUVec = (0:size(LFdec,4)-1) * HexAspect;
        
        NewUVec = (0:ceil(LFSize(4)*HexAspect)-1);
        NewVVec = (0:LFSize(3)-1);
        LFSize(4) = length(NewUVec);
        LF2 = zeros(LFSize, DecodeOptions.Precision);
        
        [Oldvv,Olduu] = ndgrid(OldVVec,OldUVec);
        [Newvv,Newuu] = ndgrid(NewVVec,NewUVec);
        if( DecodeOptions.DoDehex )
%             fprintf(' and removing hex sampling...');
            FirstShiftRow = NewLensletGridModel.FirstPosShiftRow;
            Olduu(FirstShiftRow:2:end,:) = Olduu(FirstShiftRow:2:end,:) + HexAspect/2;
        else
%             fprintf('...');
        end
        
        DT = delaunayTriangulation( Olduu(:), Oldvv(:) );  % use DelaunayTri in older Matlab versions
        [ti,bc] = pointLocation(DT, Newuu(:), Newvv(:));
        ti(isnan(ti)) = 1;
        
        for( ColChan = 1:size(LFdec,5) )
%             fprintf('.');
            for( tidx= 1:LFSize(1) )
                for( sidx= 1:LFSize(2) )
                    CurUVSlice = squeeze(LFdec(tidx,sidx,:,:,ColChan));
                    triVals = CurUVSlice(DT(ti,:));
                    CurUVSlice = dot(bc',triVals')';
                    CurUVSlice = reshape(CurUVSlice, [length(NewVVec),length(NewUVec)]);
                    
                    CurUVSlice(isnan(CurUVSlice)) = 0;
                    LF2(tidx,sidx, :,:, ColChan) = CurUVSlice;
                end
            end
        end
        LFdec = LF2;
        clear LF2
        DecodeOptions.OutputScale(3) = DecodeOptions.OutputScale(3) * HexAspect;
        
    otherwise
        fprintf('\nNo valid dehex / resampling selected\n');
end

%---Resize to square s,t pixels---
% Assumes only a very slight resampling is required, resulting in an identically-sized output light field
if( DecodeOptions.DoSquareST )
%     fprintf('\nResizing to square s,t pixels using 1D linear interp...');
    
    ResizeScale = DecodeOptions.OutputScale(1)/DecodeOptions.OutputScale(2);
    ResizeDim1 = 1;
    ResizeDim2 = 2;
    if( ResizeScale < 1 )
        ResizeScale = 1/ResizeScale;
        ResizeDim1 = 2;
        ResizeDim2 = 1;
    end
    
    OrigSize = size(LFdec, ResizeDim1);
    OrigVec = floor((-(OrigSize-1)/2):((OrigSize-1)/2));
    NewVec = OrigVec ./ ResizeScale;
    
    OrigDims = [1:ResizeDim1-1, ResizeDim1+1:5];
    
    UBlkSize = 32;
    USize = size(LFdec,4);
    LFdec = permute(LFdec,[ResizeDim1, OrigDims]);
    for( UStart = 1:UBlkSize:USize )
        UStop = UStart + UBlkSize - 1;
        UStop = min(UStop, USize);
        LFdec(:,:,:,UStart:UStop,:) = interp1(OrigVec, LFdec(:,:,:,UStart:UStop,:), NewVec);
%         fprintf('.');
    end
    LFdec = ipermute(LFdec,[ResizeDim1, OrigDims]);
    LFdec(isnan(LFdec)) = 0;
    
    DecodeOptions.OutputScale(ResizeDim2) = DecodeOptions.OutputScale(ResizeDim2) * ResizeScale;
end


%---Trim s,t---
LFdec = LFdec(2:end-1,2:end-1, :,:, :);

%---Slice out LFWeight if it was requested---
if( nargout >= 2 )
    LFWeight = LFdec(:,:,:,:,end);
    LFWeight = LFWeight./max(LFWeight(:));
    LFdec = LFdec(:,:,:,:,1:end-1);
end


%gamma and colour correction

DecodeOptions.Gamma = 1/2.2;
% DecodeOptions.OptionalTasks = {[]};
LFdecC = ColourCorrect( LFdec, LFMetadata, DecodeOptions );

end

function LFdec = ColourCorrect( LFdec, LFMetadata, DecodeOptions )
% fprintf('Applying colour correction... ');
% LFdec = LFdec./max(LFdec(:));
%---Apply the color conversion and saturate---
LFdec = LFColourCorrect( LFdec, DecodeOptions.ColourMatrix, DecodeOptions.ColourBalance, DecodeOptions.Gamma);

end

%------------------------------------------------------------------------------------------------------
function LF = SliceXYImage( LensletGridModel, LensletImage, ~, DecodeOptions )
% todo[optimization]: The SliceIdx and ValidIdx variables could be precomputed

% fprintf('\nSlicing lenslets into LF...');

USize = LensletGridModel.UMax;
VSize = LensletGridModel.VMax;
MaxSpacing = max(LensletGridModel.HSpacing, LensletGridModel.VSpacing);  % Enforce square output in s,t
SSize = MaxSpacing + 1; % force odd for centered middle pixel -- H,VSpacing are even, so +1 is odd
TSize = MaxSpacing + 1;

LF = zeros(TSize, SSize, VSize, USize, DecodeOptions.NColChans + DecodeOptions.NWeightChans, DecodeOptions.Precision);

TVec = cast(floor((-(TSize-1)/2):((TSize-1)/2)), 'int16');
SVec = cast(floor((-(SSize-1)/2):((SSize-1)/2)), 'int16');
VVec = cast(0:VSize-1, 'int16');
UBlkSize = 32;
for( UStart = 0:UBlkSize:USize-1 )  % note zero-based indexing
    UStop = UStart + UBlkSize - 1;
    UStop = min(UStop, USize-1);
    UVec = cast(UStart:UStop, 'int16');
    
    [tt,ss,vv,uu] = ndgrid( TVec, SVec, VVec, UVec );
    
    %---Build indices into 2D image---
    LFSliceIdxX = LensletGridModel.HOffset + uu.*LensletGridModel.HSpacing + ss;
    LFSliceIdxY = LensletGridModel.VOffset + vv.*LensletGridModel.VSpacing + tt;
    
    HexShiftStart = LensletGridModel.FirstPosShiftRow;
    LFSliceIdxX(:,:,HexShiftStart:2:end,:) = LFSliceIdxX(:,:,HexShiftStart:2:end,:) + LensletGridModel.HSpacing/2;
    
    %---Lenslet mask in s,t and clip at image edges---
    CurSTAspect = DecodeOptions.OutputScale(1)/DecodeOptions.OutputScale(2);
    R = sqrt((cast(tt,DecodeOptions.Precision)*CurSTAspect).^2 + cast(ss,DecodeOptions.Precision).^2);
    ValidIdx = find(R < LensletGridModel.HSpacing/2 & ...
        LFSliceIdxX >= 1 & LFSliceIdxY >= 1 & LFSliceIdxX <= size(LensletImage,2) & LFSliceIdxY <= size(LensletImage,1) );
    
    %--clip -- the interp'd values get ignored via ValidIdx--
    LFSliceIdxX = max(1, min(size(LensletImage,2), LFSliceIdxX ));
    LFSliceIdxY = max(1, min(size(LensletImage,1), LFSliceIdxY ));
    
    %---
    LFSliceIdx = sub2ind(size(LensletImage), cast(LFSliceIdxY,'int32'), ...
        cast(LFSliceIdxX,'int32'), ones(size(LFSliceIdxX),'int32'));
    
    tt = tt - min(tt(:)) + 1;
    ss = ss - min(ss(:)) + 1;
    vv = vv - min(vv(:)) + 1;
    uu = uu - min(uu(:)) + 1 + UStart;
    LFOutSliceIdx = sub2ind(size(LF), cast(tt,'int32'), cast(ss,'int32'), ...
        cast(vv,'int32'),cast(uu,'int32'), ones(size(ss),'int32'));
    
    %---
    for( ColChan = 1:DecodeOptions.NColChans )
        LF(LFOutSliceIdx(ValidIdx) + numel(LF(:,:,:,:,1)).*(ColChan-1)) = ...
            LensletImage( LFSliceIdx(ValidIdx) + numel(LensletImage(:,:,1)).*(ColChan-1) );
    end
%     if( DecodeOptions.NWeightChans ~= 0 )
%         LF(LFOutSliceIdx(ValidIdx) + numel(LF(:,:,:,:,1)).*(DecodeOptions.NColChans)) = ...
%             WhiteImage( LFSliceIdx(ValidIdx) );
%     end
%     fprintf('.');
end
end