CXX = g++

SOURCES = runSaliency.cpp Saliency/GMRsaliency.cpp SLIC/SLIC.cpp
OBJS = $(SOURCES:.cpp=.o)

CXXFLAGS = -I. -I/usr/local/include \
            -std=c++11 -stdlib=libc++ \
            -g3 -Wall -O0

LDFLAGS = -L/usr/lib -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lm -ljpeg

.o:
	$(CXX) $(CXXFLAGS) -o $@ -c $^

all: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o bin/gmr-saliency $(OBJS)

clean:
	rm -rf *.o */*.o
