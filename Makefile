CXX = g++

SOURCES = runSaliency.cpp Saliency/GMRsaliency.cpp Superpixel/SLIC.cpp
OBJS = $(SOURCES:.cpp=.o)

CXXFLAGS = -I. -I/usr/local/include \
            -std=c++11 -stdlib=libc++ \
            -g3 -Wall -O0
            # -std=c++0x -arch x86_64 -stdlib=libc++ \

LDFLAGS = -L/usr/local/lib -L/usr/lib $(pkg-config --libs --cflags opencv) -lm -ljpeg
LDFLAGS = -L/usr/local/lib -L/usr/lib -I/usr/local/include/opencv -I/usr/local/include -L/usr/local/lib -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lm -ljpeg

.o:
	$(CXX) $(CXXFLAGS) -o $@ -c $^

all: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o out $(OBJS)

clean:
	rm -rf *.o