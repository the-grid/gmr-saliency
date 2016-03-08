/* saliency.cpp - Saliency heuristics
 * (c) 2014-2015 The Grid
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

#define MINSIZE 50

using namespace std;

RNG rng(12345);

Mat DrawHistogram(Mat gray) {
  int histSize = 256;    // bin size
  float range[] = { 0, 255 };
  const float *ranges[] = { range };
  MatND hist;

  calcHist( &gray, 1, 0, Mat(), hist, 1, &histSize, ranges, true, false );

  int hist_w = 512; int hist_h = 400;
  int bin_w = cvRound( (double) hist_w/histSize );

  Mat histImage( hist_h, hist_w, CV_8UC1, Scalar( 0,0,0) );
  normalize(hist, hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );

  for( int i = 1; i < histSize; i++){
    line( histImage, Point( bin_w*(i-1), hist_h - cvRound(hist.at<float>(i-1)) ) ,
        Point( bin_w*(i), hist_h - cvRound(hist.at<float>(i)) ),
        Scalar( 255, 0, 0), 2, 8, 0  );
  }
  return histImage;
}

string jsonify(Rect &bigRect,
    int big_id,
    vector<Rect> &boundRect,
    vector<vector<Point> > &contours_poly,
    vector<Point2f> &center,
    vector<float> &radius,
    float entropy) {
  ostringstream out;

  out << "{\"saliency\": ";
  float x = bigRect.tl().x;
  float y = bigRect.tl().y;
  float w = abs(x-bigRect.br().x);
  float h = abs(y-bigRect.br().y);

  out <<   "{\"bounding_rect\": ["  << bigRect.tl() << ", " << bigRect.br() << "],";
  out <<    "\"bbox\": {\"x\": " <<x<< ", \"y\": " <<y<< ", \"width\": " <<w<< ", \"height\": " <<h<< "},";
  out <<    "\"confidence\": " << entropy << ",";

  out <<    "\"polygon\": [";
  size_t maxPoly = contours_poly[big_id].size()-1;
  for (size_t j = 0; j < maxPoly; ++j) {
    out << contours_poly[big_id][j] << ", ";
  }
  out << contours_poly[big_id][maxPoly] << "], ";
  out <<    "\"center\": [" << (int)center[big_id].x << ", " << (int)center[big_id].y << "], ";
  out <<    "\"radius\": " << radius[big_id] << ", ";
  // Regions
  out <<    "\"regions\": [";
  for (size_t i=0, max=boundRect.size(); i<max; ++i) {
    out <<     "{\"polygon\": [";
    size_t maxPoly = contours_poly[i].size()-1;
    for (size_t j = 0; j < maxPoly; ++j) {
      out << "{\"x\": " << contours_poly[i][j].x << ", \"y\": " << contours_poly[i][j].y << "}, ";
    }
    out << "{\"x\": " << contours_poly[i][maxPoly].x << ", \"y\": " << contours_poly[i][maxPoly].y << "}], ";
    out <<       "\"center\": {\"x\": " << (int)center[i].x << ", \"y\": " << (int)center[i].y << "}, ";
    out <<       "\"radius\": " << radius[i] << ", ";
    float x = boundRect[i].tl().x;
    float y = boundRect[i].tl().y;
    float w = abs(x-boundRect[i].br().x);
    float h = abs(y-boundRect[i].br().y);
    if (i == max-1) {
      out <<    "\"bbox\": {\"x\": " <<x<< ", \"y\": " <<y<< ", \"width\": " <<w<< ", \"height\": " <<h<< "}}";
    } else {
      out <<    "\"bbox\": {\"x\": " <<x<< ", \"y\": " <<y<< ", \"width\": " <<w<< ", \"height\": " <<h<< "}},";
    }
  }
  out << "]}}" << endl;
  return out.str();
}

static void display_help(string program_name) {
  cerr << "Usage: " << program_name << " <original image>" << endl;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    display_help(argv[0]);
    return 1;
  }

	char original_image_path[256];
	strcpy(original_image_path, argv[1]);

  Mat original_image;
  original_image = imread(original_image_path, CV_LOAD_IMAGE_COLOR);
  // Return null saliency if fails opening the image file
  if (original_image.empty()) {
    original_image = imread(original_image_path, CV_LOAD_IMAGE_COLOR);
    if (original_image.empty()) {
      cout << "{\"saliency\": null}" << endl;
      return 0;
    }
  }
  // Return whole image as saliency for images with dimensions less than minSize
  if (original_image.rows < MINSIZE || original_image.cols < MINSIZE) {
    int w = original_image.cols;
    int h = original_image.rows;
    int big_id = 0;

    Rect bigRect = Rect(0, 0, w, h);
    vector<Rect> boundRect;
    boundRect.push_back(bigRect);

    vector<Point> points;
    points.push_back(Point(0,0));
    points.push_back(Point(0,h));

    vector<vector<Point> > contours_poly;
    contours_poly.push_back(points);

    vector<Point2f> center;
    center.push_back(Point2f(w/2, h/2));

    vector<float> radius;
    radius.push_back(w);

    float entropy = 1.0;

    string json = jsonify(bigRect, big_id, boundRect, contours_poly, center, radius, entropy);
    cout << json;
    return 0;
  }
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

  #ifdef DEBUG
  Mat histin = DrawHistogram(saliency_gray);
  sprintf(file_path, "%s_histogram_saliency.png", original_image_path);
  imwrite(file_path, histin);
  #endif

  // Calculate confidence based on homogeneity of saliency map's histogram
  Mat hist;
  int histSize = 256;
  float range[] = { 0, 256 } ;
  const float* histRange = { range };
  calcHist(&saliency_gray, 1, 0, Mat(), hist, 1, &histSize, &histRange, true, false);
  hist /= original_image.size().height*original_image.size().width;
  Mat logP;
  cv::log(hist,logP);
  // Inverse normalized entropy
  float entropy = -1*sum(hist.mul(logP)).val[0];
  entropy = entropy/log(256); // normalize
  entropy = 1.0 - entropy; // inverse

  // Blur and binary threshold saliency map based on OTSU
	saliency_gray.convertTo(saliency_gray, CV_8U); // threshold needs an int Mat
  Mat blur;
  bilateralFilter(saliency_gray, blur, 12, 24, 6);
  // GaussianBlur(saliency_gray, blur, Size(5,5), 0);
  threshold(blur, most_salient, 0, 255, THRESH_BINARY + THRESH_OTSU);
  #ifdef DEBUG
	sprintf(file_path, "%s_threshold.png", original_image_path);
	imwrite(file_path, most_salient);
  #endif

	// Eliminate small regions (Mat() == default 3x3 kernel)
	Mat filtered;
  //filtered = most_salient;
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
  float xmin, xmax, ymin, ymax;
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
  }
  Rect bigRect = Rect(xmin, ymin, xmax-xmin, ymax-ymin);

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
  string json = jsonify(bigRect, big_id, boundRect, contours_poly, center, radius, entropy);
  cout << json;

	return 0;
}
