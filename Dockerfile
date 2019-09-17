FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y build-essential cmake python2.7-dev libboost-python-dev \
	wget zlib1g-dev libxerces-c-dev xorg-dev libx11-dev xorg-dev libglu1-mesa-dev \
	freeglut3-dev libglew1.5 libglew1.5-dev libglu1-mesa libglu1-mesa-dev \
	libgl1-mesa-glx libgl1-mesa-dev nano joe 
WORKDIR /root
RUN wget -c https://github.com/Geant4/geant4/archive/v10.4.2.tar.gz -O - | tar -xz
RUN mkdir geant4build
WORKDIR /root/geant4build
RUN cmake -DGEANT4_INSTALL_DATA=OFF -DGEANT4_USE_GDML=ON \
	-DGEANT4_BUILD_EXAMPLES=OFF \
	-DGEANT4_BUILD_CXXSTD=c++14 \
	-DGEANT4_BUILD_MULTITHREADED=OFF \
	-DGEANT4_USE_SYSTEM_ZLIB=ON \
	-DGEANT4_USE_SYSTEM_EXPAT=ON \
	-DGEANT4_USE_USOLIDS=OFF \
	-DGEANT4_USE_OPENGL_X11=ON \
	-DCMAKE_INSTALL_PREFIX=/root/geant4 \
	/root/geant4-10.4.2
RUN make -j4 
RUN make install
WORKDIR /root
ENV GEANT4_INSTALL /root/geant4
RUN mkdir g4pybuild
WORKDIR /root/g4pybuild
RUN cmake /root/geant4-10.4.2/environments/g4py/
RUN make -j4
RUN make install
RUN mv /root/geant4-10.4.2/environments/g4py/lib /root/geant4/g4py 
ENV PYTHONPATH $PYTHONPATH:/root/geant4/g4py
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/root/geant4/lib
RUN mkdir /root/geant4/share/Geant4-10.4.2/data
WORKDIR /root/geant4/share/Geant4-10.4.2/data
RUN wget -c http://cern.ch/geant4-data/datasets/G4ENSDFSTATE.2.2.tar.gz -O - | tar -xz
RUN wget -c http://cern.ch/geant4-data/datasets/G4EMLOW.7.3.tar.gz -O - | tar -xz
ENV G4ENSDFSTATEDATA /root/geant4/share/Geant4-10.4.2/data/G4ENSDFSTATE2.2
ENV G4LEDATA /root/geant4/share/Geant4-10.4.2/data/G4EMLOW7.3
WORKDIR /root 
RUN rm -rf g4pybuild geant4-10.4.2 geant4build

# install the notebook package
RUN pip install --no-cache --upgrade pip && \
	pip install --no-cache notebook

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}
WORKDIR ${HOME}
USER ${USER}