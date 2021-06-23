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
      vim-nox\
      xfce4-terminal \
      xterm \
      tzdata rsync wget supervisor
RUN apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Download url is: https://update.code.visualstudio.com/commit:${commit_id}/server-linux-x64/stable
RUN curl -sSL "https://update.code.visualstudio.com/latest/server-linux-x64/stable" -o /tmp/vscode-server-linux-x64.tar.gz

RUN sudo mkdir -p /home/ubuntu/.vscode-server/bin/latest
# assume that you upload vscode-server-linux-x64.tar.gz to /tmp dir
RUN tar zxvf /tmp/vscode-server-linux-x64.tar.gz -C /home/ubuntu/.vscode-server/bin/latest --strip 1
RUN touch /home/ubuntu/.vscode-server/bin/latest/0

RUN sudo chown -R ubuntu:ubuntu /home/ubuntu/.vscode-server/

#RUN apt-get update

RUN apt-get update
RUN sudo apt-get install -y --no-install-recommends ros-melodic-rqt-graph
RUN sudo apt-get install -y --no-install-recommends ros-melodic-rqt-image-view

RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt update
RUN apt install -y --no-install-recommends google-chrome-stable \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*



#RUN curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
#RUN sudo apt update
#RUN sudo apt install -y google-chrome-stable


#RUN wget -qO- https://deb.opera.com/archive.key | sudo apt-key add - 
#RUN echo deb https://deb.opera.com/opera-stable/ stable non-free | sudo tee /etc/apt/sources.list.d/opera.list 
#RUN apt update 
#RUN apt install -y opera-stable 

USER ubuntu
WORKDIR /home/ubuntu/

ADD ./app /app
RUN sudo chown ubuntu:ubuntu /app/startup.sh;sudo chmod +x /app/startup.sh

ENTRYPOINT ["/app/startup.sh"]
