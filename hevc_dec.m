% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function dec_command = hevc_dec(bin_filename, dec_filename)
dec_bin = '.\bin\jem4lf\TAppDecoder.exe';
dec_command = [dec_bin, ' -b ', bin_filename, ' -o ', dec_filename, ' -d 8'];
