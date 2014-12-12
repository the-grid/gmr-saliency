#ifndef _SLIC_H
#define _SLIC_H

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <vector>

using namespace cv;
using namespace std;

class SLIC {
public:
  SLIC();
  ~SLIC();

  // Calculate the SLIC segmentation of a given image
  void Run(const Mat im, const int K, const int compactness, const int max_iteration);

  // Get an int matrix with labels
  Mat GetLabels();

  // Write cluster labels to an image file
  void WriteLabelsToFile(String file_path);

private:
  int compactness;
  int S;
  int K;
  int width;
  int height;
  int min_x;
  int min_y;
  Mat labels;
  Mat image;
  Mat neighbors;

private:
  float distance_between_points(
    Point2i coords1,
    Point2i coords2,
    Vec3f lab1,
    Vec3f lab2
  );
  void find_neighbors_of(Point2i point);
};

#endif