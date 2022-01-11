FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04
RUN apt update
RUN apt -y upgrade
RUN apt install -y wget git pip
RUN apt-get update && apt-get upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y software-properties-common
RUN apt install -y apt-file
RUN apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
RUN apt-get install -y python3-numpy libtbb2 libtbb-dev
RUN apt-get install -y libjpeg-dev libpng-dev libtiff5-dev libdc1394-22-dev libeigen3-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev sphinx-common libtbb-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libavutil-dev libavfilter-dev libavresample-dev
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt update
RUN apt install libjasper1 libjasper-dev

RUN cd /opt
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

RUN cd opencv
RUN mkdir release
RUN cd release
RUN cmake -D BUILD_TIFF=ON -D WITH_CUDA=ON -D WITH_CUDNN=ON -D ENABLE_AVX=OFF -D WITH_OPENGL=OFF -D WITH_OPENCL=OFF -D WITH_IPP=OFF -D WITH_TBB=ON -D BUILD_TBB=ON -D WITH_EIGEN=OFF -D WITH_V4L=OFF -D WITH_VTK=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D OPENCV_GENERATE_PKGCONFIG=ON -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules /opt/opencv/
RUN make -j16
RUN make install
RUN ldconfig
RUN cd ~

RUN cp /usr/local/lib/pkgconfig/opencv4.pc  /usr/lib/x86_64-linux-gnu/pkgconfig/opencv.pc
RUN pkg-config --modversion opencv

RUN git clone https://github.com/AlexeyAB/darknet.git
RUN cd darknet
RUN sed -i 's/OPENCV=0/OPENCV=1/' Makefile
RUN sed -i 's/GPU=0/GPU=1/' Makefile
RUN sed -i 's/CUDNN=0/CUDNN=1/' Makefile
RUN sed -i 's/CUDNN_HALF=0/CUDNN_HALF=1/' Makefile
RUN sed -i 's/LIBSO=0/LIBSO=1/' Makefile
RUN make 
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights
RUN ./darknet detector test cfg/coco.data cfg/yolov4.cfg yolov4.weights data/dog.jpg
