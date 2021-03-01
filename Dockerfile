FROM ros:melodic-ros-base
LABEL maintainer="IGK"

ENV DEBIAN_FRONTEND noninteractive

RUN echo "Set disable_coredump false" >> /etc/sudo.conf

RUN sudo apt-get install git -y \
	&& cd /root && git clone https://github.com/KMiyawaki/setup_robot_programming.git

WORKDIR /root/setup_robot_programming
RUN ./stop_update.sh
RUN ./install_basic_packages.sh
RUN ./install_python_packages.sh
RUN ./install_chrome.sh

RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu \
    && echo ubuntu:ubuntu | chpasswd \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN sudo apt-get install -y gosu

# tini to fix subreap
ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN sudo chmod +x /bin/tini

#ros Packages
RUN sudo apt-get install -y --no-install-recommends ros-melodic-cv-camera \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-image-transport \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-image-transport-plugins \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-joint-state-publisher-gui \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-joy \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-laser-filters \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-laser-pipeline \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-map-server \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-mouse-teleop \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-navigation \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-robot-state-publisher \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-rosbash \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-rviz \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-slam-gmapping \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-stage-ros \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-rosbridge-suite \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-teleop-twist-joy \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-teleop-twist-keyboard \
	&& sudo apt-get install -y --no-install-recommends ros-melodic-xacro

RUN apt-get update && \
    # Install the required packages for desktop    
    apt-get install -y \
      supervisor \
      xvfb \
      xfce4 \
      x11vnc \
      && \
    # Install utilities(optional).
    apt-get install -y \
      wget \
      curl \
      net-tools \
      vim-tiny \
      xfce4-terminal \
      tzdata rsync wget supervisor
RUN apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

ADD ./app /app

USER ubuntu

COPY ./install_sigverse.sh ./install_sigverse.sh
RUN sudo chmod +x ./install_sigverse.sh && bash ./install_sigverse.sh

WORKDIR /home/ubuntu/

RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && sudo dpkg -i code.deb && sudo rm -f code.deb
#RUN sh -c '/bin/echo -e "y" | code --install-extension DavidAnson.vscode-markdownlint --force'
ENV DONT_PROMPT_WSL_INSTALL TRUE
RUN code --install-extension DavidAnson.vscode-markdownlint --force
RUN code --install-extension DotJoshJohnson.xml --force && \
	code --install-extension eamodio.gitlens --force && \
	code --install-extension mhutchie.git-graph --force && \
	code --install-extension Kelvin.vscode-sshfs --force && \
	code --install-extension ms-iot.vscode-ros --force && \
	code --install-extension ms-python.python --force && \
	code --install-extension ms-vscode.cpptools --force && \
	code --install-extension shakram02.bash-beautify --force && \
	code --install-extension yzhang.markdown-all-in-one --force



#RUN sudo chown -R ubuntu:ubuntu /home/ubuntu/setup_robot_programming/
RUN git clone https://github.com/SIGVerse/sigverse_ros_package.git


ENTRYPOINT ["/app/startup.sh"]
#CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

#ADD ./startup.sh ./startup.sh

#USER ubuntu

#ENTRYPOINT ["/root/setup_robot_programming/startup.sh"]
#EXPOSE 8080
