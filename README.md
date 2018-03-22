# Pseudo-Sequence-Based Light Field Image Compression
We here provide the source code of our paper:

Dong Liu, Lizhi Wang, Li Li, Zhiwei Xiong, Feng Wu, Wenjun Zeng: Pseudo-sequence-based light field image compression. 2016 IEEE International Conference on Multimedia and Expo Workshops (ICMEW). Seattle, WA, USA, Jul 11-15, 2016. [link](http://dx.doi.org/10.1109/ICMEW.2016.7574674)

Contact: Dong Liu (dongeliu#ustc.edu.cn)

How to use
----------
1. You need Windows and MATLAB
2. Download the test data from [here](https://pan.baidu.com/s/1qI_woYZTW2NzagWzUe2LoQ)
3. Install the light field toolbox from [here](http://www.mathworks.com/matlabcentral/fileexchange/49683-light-field-toolbox-v0-4)
4. Try with demo.m
5. Feel free to hack!

FAQ
---
Why is the program so slow?

A: It invokes the JEM video encoder to compress the pseudo sequence, which is very slow. On my own computer it takes around __2 hours__ to encode one light field. If you are an expert of video coding, you can surely use other encoders to replace JEM, by making changes in hevc_enc.m. If you want to quickly verify the program, you can download our coded bitstream [here](https://pan.baidu.com/s/1iA3uDZkSxgvq8B11HZmZbQ), put it into the folder "results", and comment the code
```MATLAB
encoder(img, rate);
```
in demo.m. Then it only invokes decoder and quality evaluation.

Why is there only one test image?

A: Please refer to the original link [here](https://mmspg.epfl.ch/EPFL-light-field-image-dataset) for all the 12 test light field images.
