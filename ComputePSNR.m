% Author: Martin Rerabek (martin.rerabek@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script which computes PSNR values as defined in CFP:
% http://mmspg.epfl.ch/files/content/sites/mmspl/files/shared/LF-GC/Call_For_Proposals_Final.pdf

% Input:
% R - LF data structure created from uncompressed lenslet image in uint8
% I - LF data structure created from compressed bitstream in uint8

% Output:
%  PSNR values per channel and for YUV image according to the CfP mentioned
%  above.

% Note:
% Removing the comments at the end allows to save PSNR values to PSNRs.mat in the current directory

function [PSNR_Y, PSNR_U, PSNR_V, PSNR_YUV, PSNR_Y_mean, PSNR_U_mean, PSNR_V_mean, PSNR_YUV_mean] = ComputePSNR(I, R)
% removing weighting channel if needed
I = I(:,:,:,:,1:3);
R = R(:,:,:,:,1:3);
m = size(I,1);
n = size(I,2);
for k = 1:m
    for l = 1:n
        Iyuv = rgb2ycbcr(squeeze(I(k,l,:,:,:)));
        Ryuv = rgb2ycbcr(squeeze(R(k,l,:,:,:)));
        Iyuv = im2double(Iyuv);
        Ryuv = im2double(Ryuv);
        
        ds = (Iyuv(:,:,1) - Ryuv(:,:,1)).^2;
        MSE_Y(k,l) = mean(ds(:));
        PSNR_Y(k,l) = 10*log10(1/MSE_Y(k,l));
        
        ds = (Iyuv(:,:,2) - Ryuv(:,:,2)).^2;
        MSE_U(k,l) = mean(ds(:));
        PSNR_U(k,l) = 10*log10(1/MSE_U(k,l));
        
        ds = (Iyuv(:,:,3) - Ryuv(:,:,3)).^2;
        MSE_V(k,l) = mean(ds(:));
        PSNR_V(k,l) = 10*log10(1/MSE_V(k,l));
        
        PSNR_YUV(k,l) = (6*PSNR_Y(k,l)+PSNR_U(k,l)+PSNR_V(k,l))/8;
    end
end
PSNR_Y = PSNR_Y(2:end-1,2:end-1);
PSNR_U = PSNR_U(2:end-1,2:end-1);
PSNR_V = PSNR_V(2:end-1,2:end-1);
PSNR_YUV = PSNR_YUV(2:end-1,2:end-1);

PSNR_Y(isinf(PSNR_Y)) = NaN;
PSNR_U(isinf(PSNR_U)) = NaN;
PSNR_V(isinf(PSNR_V)) = NaN;
PSNR_YUV(isinf(PSNR_YUV)) = NaN;

PSNR_Y_mean = nanmean(PSNR_Y(:));
PSNR_U_mean = nanmean(PSNR_U(:));
PSNR_V_mean = nanmean(PSNR_V(:));
PSNR_YUV_mean = nanmean(PSNR_YUV(:));

% save('PSNRs.mat','PSNR_Y', 'PSNR_U', 'PSNR_V', 'PSNR_YUV', 'PSNR_Y_mean', ' PSNR_U_mean', 'PSNR_V_mean','PSNR_YUV_mean')

