#!/bin/bash

sudo gosu root ln -sfn /catkin_ws /home/ubuntu/catkin_ws

# init workspace
TARGET_ROS="melodic"
echo "**Making workspace. Target ros-${TARGET_ROS}**"
#ROS_SETUP="/opt/ros/${TARGET_ROS}/setup.bash"
#echo "source ${ROS_SETUP}" >> ~/.bashrc

source /opt/ros/${TARGET_ROS}/setup.bash

sudo chown ubuntu:ubuntu -R /catkin_ws

mkdir -p /catkin_ws/src && cd /catkin_ws/src && catkin_init_workspace || true

cd /home/ubuntu/sigverse_ros_package && git pull origin master && rsync -av  /home/ubuntu/sigverse_ros_package/ /home/ubuntu/catkin_ws/src/sigverse_ros_package/ --exclude '.git/' && cd /home/ubuntu/catkin_ws/ && catkin_make

WS_SETUP="/catkin_ws/devel/setup.bash"
echo "source ~${WS_SETUP}" >> ~/.bashrc

sudo chown ubuntu:ubuntu -R /catkin_ws


sudo gosu root /bin/tini -- supervisord -n -c /app/supervisord.conf
