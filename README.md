GMR Saliency Map [![Build Status](https://secure.travis-ci.org/the-grid/gmr-saliency.png?branch=master)](http://travis-ci.org/the-grid/gmr-saliency)
===

![saliency map examples](http://i.imgur.com/HtFpSQJ.png)

C++ implementation for paper "Saliency Detection via Graph-Based Manifold Ranking" by Chuan Yang, Lihe Zhang, Huchuan Lu, Xiang Ruan and Ming-Hsuan Yang. To appear in Proceedings of IEEE Conference on Computer Vision and Pattern Recognition (CVPR 2013), Portland, June, 2013.

This implementation was written originally by Chuan Yang
<ycscience86@gmail.com> (3-clause BSD license) and uses an also open
source SLIC implementation written by Vilson Vieira/The Grid
<vilson@thegrid.io>.

It was ported and tested on MacOS X 10.9.5 and Ubuntu Linux 14.04
using GNU C++ Compiler and OpenCV 2.4.9..

Depencencies
===

- OpenCV

Using
===

In a NodeJS environment:

```
npm install
grunt
./build/Release foo.png
```

With common C++ compiler:

```
make
./gmr-saliency foo.png
```

You can also import `gmr-saliency` into your NoFlo project and use the
`GetSaliency` component to extract saliency maps from JPG/PNG image
files or canvas while in browser.
