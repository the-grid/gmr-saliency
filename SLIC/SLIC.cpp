/* SLIC.cpp - SLIC segmentation
 * (c) 2014 The Grid
 * This SLIC implementation my be freely distributed under the BSD license
 *
 * Based on the original paper:
 * http://infoscience.epfl.ch/record/149300/files/SLIC_Superpixels_TR_2.pdf
 *
 * Using a regular grid instead of a K-defined one, as suggested by:
 * http://web.mit.edu/dron/www/portfolio/slic.html
 */

#include "SLIC.h"

SLIC::SLIC() {
}

SLIC::~SLIC() {
}

void SLIC::Run(const Mat original_image,
	             const int K,
	             const int compactness,
	             const int max_iteration) {
	this->width = original_image.cols;
  this->height = original_image.rows;
  int N = sqrt(K);
	float dx = width / float(N);
	float dy = height / float(N);

	this->K = K;
	this->S = (dx + dy + 1)/2;
	this->compactness = compactness;

	// Normalize original image between 0 and 1.0
	Mat normalized_image;
	original_image.convertTo(normalized_image, CV_32F, 1.0/255.0);
	
	// Convert normalized image from BGR to CIELAB
	Mat lab_image;
	cvtColor(normalized_image, lab_image, CV_BGR2Lab);
	this->image = normalized_image;

	// TODO: Use dinamic grid instead of regular one
	// int N_ = height*width;
	// int K_ = 194;
	// int sp_size = N_/K_;
	// int S_ = sqrt(sp_size); // grid interval
	// this->S = S_;
	// cout << height << " " << width << " " << sp_size << " " << S_ << " " << K_ << endl;

	// vector<Point2i> centroids;
	// for (int i=0; i<height-S_; i+=S_) {
	// 	for (int j=0; j<width-S_; j+=S_) {
	// 		float ci = (i + (i+S_))/2;
	// 		float cj = (j + (j+S_))/2;
	// 		//cout << i << " " << j << " " << ci << " " << cj << endl;
	// 		centroids.push_back(Point2f(ci, cj));
	// 	}
	// }

	// Initialize centroids on a regular grid
	vector<Point2i> centroids;
	for (int i = 0; i < N; ++i) {
		for (int j = 0; j < N; ++j) {
			centroids.push_back(Point2f( dx*i + dx/2, 
				                           dy*j + dy/2 ));
		}
	}
	this->centroids = centroids;

	// Initialize labels width ones and distances with "infinity"
	Mat labels = Mat(lab_image.size(), CV_32S, Scalar(1));
	Mat distances = Mat(lab_image.size(),
		                  CV_32F, 
		                  Scalar(numeric_limits<float>::max()));

	float actual_distance, last_distance;
	Mat neighbors;
	Point2i centroid_coords, neighbor_coords;
	Vec3f centroid_lab, neighbor_lab;
	
	// Iterate many times
	for (int i = 0; i < max_iteration; ++i) {

		// Iterate over all centroids (one label per centroid)
		for (int centroid = 0; centroid < centroids.size(); ++centroid) {
			// Get centroid's coordiantes and CIELAB color
			centroid_coords = centroids[centroid];
			centroid_lab = lab_image.at<Vec3f>(centroid_coords);

			// Find centroid's neighbors
			find_neighbors_of(centroid_coords);
			
			// Update neighbors to their closest centroid (like K-means)
			for (int i = 0; i < this->neighbors.rows; ++i) {
				for (int j = 0; j < this->neighbors.cols; ++j) {
					// Get centroid's neighbors coordinates and CIELAB color
					neighbor_coords = Point2i(this->min_x + j, this->min_y + i);
					neighbor_lab = lab_image.at<Vec3f>(neighbor_coords);

					actual_distance = distance_between_points(centroid_coords, 
						 																				neighbor_coords,
						 																				centroid_lab,
						 																				neighbor_lab);

					last_distance = distances.at<float>(neighbor_coords);
					
					// Update if the actual distance between centroid and pixel is less
					// than the last time it was calculated
					if (actual_distance < last_distance) {
						distances.at<float>(neighbor_coords) = actual_distance;
						labels.at<int>(neighbor_coords) = centroid;
					}
				}
			}
		}
	}
	this->labels = labels;
}

void SLIC::find_neighbors_of(Point2i point) {
	int max_x, max_y;

	// Take care of image limits while finding the window we will search on
	this->min_x = max(point.x - this->S, 0);
	max_x = min(point.x + this->S, this->width - 1);

	this->min_y = max(point.y - this->S, 0);
	max_y = min(point.y + this->S, this->height - 1);

	this->neighbors = image(Range(this->min_y, max_y),
		                      Range(this->min_x, max_x));
}

float SLIC::distance_between_points(Point2i coords1,
	       														Point2i coords2,
	       														Vec3f lab1,
	       														Vec3f lab2) {
	float color_distance = sqrt( (lab2[0] - lab1[0]) * (lab2[0] - lab1[0]) + 
   		        	               (lab2[1] - lab1[1]) * (lab2[1] - lab1[1]) + 
	  	          	             (lab2[2] - lab1[2]) * (lab2[2] - lab1[2]) );

	float spatial_distance = sqrt( (coords2.x - coords1.x) * 
		                             (coords2.x - coords1.x) + 
		                             (coords2.y - coords1.y) * 
		                             (coords2.y - coords1.y) );

	return color_distance + 
	       float(this->compactness) / float(this->S) * 
	       spatial_distance;
}

Mat SLIC::GetLabels() {
	Mat int_labels;
	this->labels.convertTo(int_labels, CV_16U);

	return int_labels;
}

void SLIC::WriteLabelsToFile(String file_path) {
	imwrite(file_path, this->labels);
}

void SLIC::WriteCentroidsToFile(String file_path) {
	Mat bgr_image;
	this->labels.convertTo(bgr_image, CV_Lab2BGR);

	for (int i=0; i<this->centroids.size(); ++i) {
		circle(bgr_image, Point(this->centroids[i].x, this->centroids[i].y), 2, Scalar(255, 0, 0), -1);
	}

	imwrite(file_path, bgr_image);
}