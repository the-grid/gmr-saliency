CXX = g++

SOURCES = saliency.cpp Saliency/GMRsaliency.cpp SLIC/SLIC.cpp

# We're not using this now, deprecated in favor of pkg-config --libs
#LDFLAGS = -L/usr/lib -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lm -ljpeg

CXXFLAGS = $(shell pkg-config --cflags opencv) -std=c++11 -g3 -Wall -O0
LDFLAGS = $(shell pkg-config --libs opencv)

all:
	$(CXX) $(CXXFLAGS) -o gmr-saliency $(SOURCES) $(LDFLAGS) 

clean:
	rm -rf *.o */*.o
