% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

function [Y, U, V] = readyuv(file, width, height)
if file < 0
    error('Invalid input file');
end
Y = fread(file, [width, height], '*uint8')';
U = fread(file, [width/2, height/2], '*uint8')';
V = fread(file, [width/2, height/2], '*uint8')';
