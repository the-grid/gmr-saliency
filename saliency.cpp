/* saliency.cpp - Saliency heuristics
 * (c) 2014 The Grid
 *
 */

#include <cstring>
#include <cstdio>
#include <iostream>
#include <string>
#include <vector>
#include "Saliency/GMRsaliency.h"

using namespace std;

RNG rng(12345);

static void display_help(string program_name) {
  cerr << "Usage: " << program_name << " <original image>"
       //<< "Options:\n"
       //<< "\t-h,--help\t\tShow this help message\n"
       //<< "\t-s,--saliencymap\tWrite the saliency map to an image file\n"
       << endl;
}

int main(int argc, char *argv[]) {
  if (argc < 1) {
    display_help(argv[0]);
    return 1;
  }

	char original_image_path[256];
	strcpy(original_image_path, argv[1]);

  Mat original_image;
  original_image = imread(original_image_path);

	GMRsaliency GMRsal;
  Mat saliency_map;
	saliency_map = GMRsal.GetSal(original_image);

	char file_path[256];
	sprintf(file_path, "%s_saliency.png", original_image_path);
	imwrite(file_path, saliency_map*255);

	// Select just the most salient region, given a threshold value
	// TODO: Try adaptive threshold? For now, OTSU's is the best
	Mat saliency_gray = saliency_map * 255;
	Mat most_salient;

	int threshold_value = 1;
	//most_salient = saliency_gray > threshold_value;
	GaussianBlur(saliency_gray, saliency_gray, Size(1,1), 0, 0);
	saliency_gray.convertTo(saliency_gray, CV_8U); // threshold needs an int Mat
	threshold(saliency_gray, most_salient, threshold_value, 255, THRESH_BINARY + THRESH_OTSU);
	sprintf(file_path, "%s_threshold.png", original_image_path);
	imwrite(file_path, most_salient);

	// Eliminate small regions (Mat() == default 3x3 kernel)
	Mat filtered;
	// dilate(most_salient, filtered, Mat(), Point(-1, -1), 2, 1, 1);
	// erode(filtered, filtered, Mat(), Point(-1, -1), 4, 1, 1);
	// dilate(filtered, filtered, Mat(), Point(-1, -1), 2, 1, 1);
	// sprintf(file_path, "%s_filtered.png", original_image_path);
	// imwrite(file_path, filtered);

	int morph_operator = 1; // 0: opening, 1: closing, 2: gradient, 3: top hat, 4: black hat
	int morph_elem = 0; // 0: rect, 1: cross, 2: ellipse
	int morph_size = 20; // 2*n + 1
  int operation = morph_operator + 2;

  Mat element = getStructuringElement( morph_elem, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );

  // Apply the specified morphology operation
  morphologyEx( most_salient, filtered, operation, element );
  sprintf(file_path, "%s_filtered.png", original_image_path);
	imwrite(file_path, filtered);

	// Calculate the bounding box
  
  // Find contours
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  findContours(filtered, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));

  // Approximate contours to polygons + get bounding rects and circles
  vector<vector<Point> > contours_poly( contours.size() );
  vector<Rect> boundRect( contours.size() );
  vector<Point2f> center( contours.size() );
  vector<float> radius( contours.size() );

  for (int i = 0; i < contours.size(); ++i) { 
  	approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
    boundRect[i] = boundingRect( Mat(contours_poly[i]) );
		minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
  }

  // Find the biggest area of all contours
  int big_id = 0;
  double big_area = 0;
  for (int i=0; i<contours.size(); ++i) {
  	// Contour area
  	double area = contourArea(contours[i]);
  	if (area > big_area) {
  		big_id = i;
  		big_area = area;
  	}
  }

  int i = big_id;
  // Draw polygonal contour + bonding rects + circles
  Mat drawing = Mat::zeros( filtered.size(), CV_8UC3 );
	//Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
	Scalar color = Scalar(255,255,255);
  //drawContours( drawing, contours_poly, i, color, 2, 8, vector<Vec4i>(), 0, Point() );
  drawContours( drawing, contours_poly, i, color, 2, 8, hierarchy);
  rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), Scalar(0,200,0), 2, 8, 0 );
  circle( drawing, center[i], (int)radius[i], Scalar(0,200,0), 2, 8, 0 );
  // Center point
  circle( drawing, center[i], 3, Scalar(0,200,0), 2, 0, 0);
  // Contour points
  for (int j=0; j<contours_poly[i].size(); ++j) {
  	circle( drawing, contours_poly[i][j], 3, Scalar(200,0,0), 2, 0, 0);
  }
  // cout << big_area << " " << contours[i].size() << " " << contours_poly[i].size() << endl;
  // cout << center[i] << endl;
  // cout << contours_poly[i] << endl;

  sprintf(file_path, "%s_contours.png", original_image_path);
  imwrite(file_path, drawing);

	return 0;
}
