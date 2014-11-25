/*
demo for paper "Saliency Detection via Graph-based Manifold Ranking"
by Chuan Yang, Lihe Zhang, Huchuan Lu, Xiang Ruan, and Ming-Hsuan Yang
in CVPR13.
written by Chuan Yang
email: ycscience86@gmail.com
date: 2013.5.7

modified by Vilson Vieira
email: vilson@void.cc
date: 2014.11.28
*/

#include <cstring>
#include "Saliency/GMRsaliency.h"

#define MAX_PATH 255

int main(int argc, char *argv[]) {
	Mat sal, img;
	char imname[MAX_PATH+1];
	strcpy(imname, argv[1]);

  img = imread(imname);
	GMRsaliency GMRsal;
	sal = GMRsal.GetSal(img);
	char salname[MAX_PATH+1];
	sprintf(salname, "%s_saliency.png", imname);
	imwrite(salname,sal*255);
  
	return 0;
}
