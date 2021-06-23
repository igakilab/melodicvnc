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

cd /home/ubuntu/catkin_ws/ && catkin_make

WS_SETUP="/catkin_ws/devel/setup.bash"
echo "source ~${WS_SETUP}" >> /home/ubuntu/.bashrc

mkdir -p /home/ubuntu/.config/xfce4/
mkdir -p /home/ubuntu/.local/share/xfce4/helpers/

cp /app/chrome/helpers.rc /home/ubuntu/.config/xfce4/
cp -n /app/chrome/custom-WebBrowser.desktop /home/ubuntu/.local/share/xfce4/helpers/
sudo cp -n /app/chrome/master_preferences /opt/google/chrome/

sudo gosu ubuntu touch /home/ubuntu/.sudo_as_admin_successful
sudo chown ubuntu:ubuntu -R /catkin_ws
sudo gosu root /bin/tini -s -- supervisord -n -c /app/supervisord.conf

