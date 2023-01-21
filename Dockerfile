FROM ros:melodic-ros-core

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential wget \
    ros-${ROS_DISTRO}-eigen-conversions ros-${ROS_DISTRO}-rviz ros-${ROS_DISTRO}-pcl-ros \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /catkin_ws/src

COPY FAST_LIO FAST_LIO
COPY livox_ros_driver livox_ros_driver

WORKDIR /catkin_ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release

WORKDIR /
COPY resources/ros_entrypoint.sh .

# Download test bag
ARG GDRIVE_BAGFILE_ID="15RDVy1U-Xv-KLVNc4NDp8TCZDVDCVErB"
ARG GDRIVE_BAGFILE_NAME="outdoor_Mainbuilding_10hz_2020-12-24-16-38-00.bag"
ENV GDRIVE_BAGFILE_NAME=${GDRIVE_BAGFILE_NAME}

RUN wget -q --load-cookies /tmp/cookies.txt \ 
    "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=$GDRIVE_BAGFILE_ID' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$GDRIVE_BAGFILE_ID" -O $GDRIVE_BAGFILE_NAME && rm -rf /tmp/cookies.txt


WORKDIR /catkin_ws

RUN echo 'alias build="catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release"' >> ~/.bashrc
RUN echo 'alias run="roslaunch fast_lio docker_rosbag_mapping_avia.launch"' >> ~/.bashrc
