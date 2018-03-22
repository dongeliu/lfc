% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function enc_command = hevc_enc(cfgs, yuv_filename, yuv_width, yuv_height, num_frames, qp, bin_filename, recon_filename)
enc_bin = '.\bin\jem4lf\TAppEncoder.exe';
if iscell(cfgs)
    cfgstr = '';
    for i = 1 : length(cfgs)
        cfgstr = [cfgstr, ' -c ', cfgs{i}];
    end
else
    cfgstr = [' -c', cfgs];
end
argstr = [' --InputFile=',yuv_filename,' --SourceWidth=',num2str(yuv_width),' --SourceHeight=',num2str(yuv_height),' --FramesToBeEncoded=',num2str(num_frames)];
qualstr = [' -q ',num2str(qp)];
outstr = [' --BitstreamFile=',bin_filename,' --ReconFile=',recon_filename];
enc_command = [enc_bin, cfgstr, argstr, qualstr, outstr];
