% Copyright (c) 2016-  Dong Liu (dongeliu@ustc.edu.cn)
% For research purpose only. Cannot be used for any other purpose without permission from the author(s).

img = 1;
rate = 4;
disp('Start encoding ...');
encoder(img, rate);
disp('Start decoding ...');
decoder(img, rate);
disp('Start quality evaluation ...');
qualeval(img, rate);
disp('Bytes and PSNR shown above, done!');