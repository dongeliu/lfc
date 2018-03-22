% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function writeyuv(file, Y, U, V)
if file < 0
    error('Invalid file');
end
fwrite(file, Y', 'uint8');
fwrite(file, U', 'uint8');
fwrite(file, V', 'uint8');
