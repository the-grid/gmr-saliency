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

// #define DEBUG
#undef DEBUG

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
  if (argc < 2) {
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

  #ifdef DEBUG
	char file_path[256];
	sprintf(file_path, "%s_saliency.png", original_image_path);
	imwrite(file_path, saliency_map*255);
  #endif

	// Select just the most salient region, given a threshold value
	Mat saliency_gray = saliency_map * 255;
	Mat most_salient;

  // Static threshold:
  // Mat fg;
  // int threshold_value = 254;
  // fg = saliency_gray >= threshold_value;
  // #ifdef DEBUG
  // sprintf(file_path, "%s_fg.png", original_image_path);
  // imwrite(file_path, fg);
  // #endif
	GaussianBlur(saliency_gray, saliency_gray, Size(1,1), 0, 0);
	saliency_gray.convertTo(saliency_gray, CV_8U); // threshold needs an int Mat
  //adaptiveThreshold(saliency_gray, most_salient, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, 3, 0);  
	threshold(saliency_gray, most_salient, 0, 255, THRESH_BINARY | THRESH_OTSU);
  #ifdef DEBUG
	sprintf(file_path, "%s_threshold.png", original_image_path);
	imwrite(file_path, most_salient);
  #endif

	// Eliminate small regions (Mat() == default 3x3 kernel)
	Mat filtered;
  // Another option is to use dilate/erode/dilate:
	// dilate(most_salient, filtered, Mat(), Point(-1, -1), 2, 1, 1);
	// erode(filtered, filtered, Mat(), Point(-1, -1), 4, 1, 1);
	// dilate(filtered, filtered, Mat(), Point(-1, -1), 2, 1, 1);
	// sprintf(file_path, "%s_filtered.png", original_image_path);
	// imwrite(file_path, filtered);

	int morph_operator = 1; // 0: opening, 1: closing, 2: gradient, 3: top hat, 4: black hat
	int morph_elem = 2; // 0: rect, 1: cross, 2: ellipse
	int morph_size = 20; // 2*n + 1
  int operation = morph_operator + 2;

  Mat element = getStructuringElement( morph_elem, Size( 2*morph_size + 1, 2*morph_size+1 ), Point( morph_size, morph_size ) );

  // Apply the specified morphology operation
  morphologyEx( most_salient, filtered, operation, element );
  #ifdef DEBUG
  sprintf(file_path, "%s_filtered.png", original_image_path);
	imwrite(file_path, filtered);
  #endif

  // Find contours
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  findContours(filtered, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));

  // Calculate convex hull based on contours
  // vector<vector<Point> > hull(contours.size());

  // Approximate contours to polygons + get bounding rects and circles
  vector<vector<Point> > contours_poly( contours.size() );
  vector<Rect> boundRect( contours.size() );
  vector<Point2f> center( contours.size() );
  vector<float> radius( contours.size() );

  for (size_t i = 0, max = contours.size(); i < max; ++i) { 
    // Approximate polygon of a contour
  	approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
    // Calculate the bounding box for the contour
    boundRect[i] = boundingRect( Mat(contours_poly[i]) );
    // Calculate the bounding circle and store in center/radius
		minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
    // Calculate convex hull and store in hull
    // convexHull(Mat(contours[i]), hull[i], false);
  }

  // Find the biggest area of all contours
  int big_id = 0;
  double big_area = 0;
  for (size_t i = 0, max = contours.size(); i < max; ++i) { 
  	// Contour area
  	double area = contourArea(contours[i]);
  	if (area > big_area) {
  		big_id = i;
  		big_area = area;
  	}
  }

  // Group all bounding rects into one, good for superimposition elimination
  // Vector<Rect> allRect = boundRect;
  // groupRectangles(boundRect, 0, INFINITY);
  // cout << boundRect.size() << endl;

  // Group bounding rects into one
  int xmin, xmax, ymin, ymax;
  xmax = 0;
  ymax = 0;
  xmin = INFINITY;
  ymin = INFINITY;  
  for (size_t j=0, max = boundRect.size(); j<max; ++j) {
    int xminB = boundRect[j].x;
    int yminB = boundRect[j].y;
    int xmaxB = boundRect[j].x + boundRect[j].width;
    int ymaxB = boundRect[j].y + boundRect[j].height;
    if (xminB < xmin)
      xmin = xminB;
    if (yminB < ymin)
      ymin = yminB;
    if (xmaxB > xmax)
      xmax = xmaxB;
    if (ymaxB > ymax)
      ymax = ymaxB;
    // cout << j << endl;
    // cout << boundRect[j].tl() << endl;
    // cout << boundRect[j].br() << endl;
  }
  // cout << xmin << "," << ymin << endl;
  // cout << xmax << "," << ymax << endl;
  Rect bigRect = Rect(xmin, ymin, xmax-xmin, ymax-ymin);
  //int i = big_id;
  #ifdef DEBUG
  // Draw polygonal contour + bonding rects + circles
  Mat drawing = Mat::zeros( filtered.size(), CV_8UC3 );
  for (size_t i=0, max=boundRect.size(); i<max; ++i) {
  
  	//Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
  	Scalar color = Scalar(255,255,255);
    //drawContours( drawing, contours_poly, i, color, 2, 8, vector<Vec4i>(), 0, Point() );
    drawContours( drawing, contours_poly, i, color, 2, 8, hierarchy);
    rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), Scalar(0,200,0), 2, 8, 0 );
    circle( drawing, center[i], (int)radius[i], Scalar(0,200,0), 2, 8, 0 );
    // Center point
    circle( drawing, center[i], 3, Scalar(0,200,0), 2, 0, 0);
    // Contour points
    for (size_t j=0, max = contours_poly[i].size(); j<max; ++j) {
    	circle( drawing, contours_poly[i][j], 3, Scalar(200,0,0), 2, 0, 0);
    }
    // Convex hull points
    //drawContours(drawing, hull, i, color, 2, 8, hierarchy);
  }
  // Draw the big rectangle
  rectangle( drawing, bigRect.tl(), bigRect.br(), Scalar(255,200,255), 2, 8, 0 );
  
  sprintf(file_path, "%s_contours.png", original_image_path);
  imwrite(file_path, drawing);

  // cout << "area: " << big_area << endl;
  // cout << "num contours: " << contours_poly[i].size() << endl;
  // cout << "center point: " << center[i] << endl;
  #endif

  // Serialize as stringified JSON
  // TODO: Use jsoncpp instead? Not using now to avoid one more dependency
  cout << "{\"saliency\": ";
  cout <<   "{\"outmost_rect\": ["  << bigRect.tl() << ", " << bigRect.br() << "],";
  cout <<    "\"regions\": [";
  for (size_t i=0, max=boundRect.size(); i<max; ++i) {
    cout <<     "{\"polygon\": [";
    size_t maxPoly = contours_poly[i].size()-1;
    for (size_t j = 0; j < maxPoly; ++j) {
      cout << contours_poly[i][j] << ", ";
    }
    cout << contours_poly[i][maxPoly] << "], ";
    cout <<       "\"center\": [" << (int)center[i].x << ", " << (int)center[i].y << "], ";
    cout <<       "\"radius\": " << radius[i] << ", ";
    if (i == max-1)
      cout <<       "\"bounding_rect\": [" << boundRect[i].tl() << ", " << boundRect[i].br() << "]}";
    else
      cout <<       "\"bounding_rect\": [" << boundRect[i].tl() << ", " << boundRect[i].br() << "]},";
  }
  cout << "]}}" << endl;

	return 0;
}
