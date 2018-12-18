FROM debian:latest

# docker run -it -p 8888:8888 -v /home/tako/testroom/SVHN/dockervolume/:/home/jpuser/dockerhostvolume 1b04afe72148
# ./.jupyter

MAINTAINER R.E.M. & co
# based lightly on https://hub.docker.com/r/continuumio/anaconda3/~/dockerfile/

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

# Took a while until I found that it should work with python 2.7 instead of 3.6
# luckily the only change was making Anaconda3 -> Anaconda2
# https://github.com/facebookresearch/loop/issues/5

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

ENV PATH /opt/conda/bin:$PATH

# Update to latest conda version
RUN conda update -n base conda

RUN conda install pytorch-cpu torchvision-cpu -c pytorch
# Make jupyter notebook available

EXPOSE 8888

# Make it possible to export PDF
# https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex.

#RUN apt-get install -y texlive-xetex

# To make a map in jupyter notebook
RUN conda install basemap
# To overcome error message in jupyter notebook 
# based on https://github.com/matplotlib/basemap/issues/419
ENV PROJ_LIB /opt/conda/share/proj/
# To make hi resolution maps
RUN conda install basemap-data-hires

# Set up jpuser
RUN useradd -m jpuser

# Set up our notebook config.
COPY tools/jupyter_notebook_config.py /home/jpuser/.jupyter/
COPY tools/run_jupyter.sh /home/jpuser/
RUN chown jpuser /home/jpuser/.jupyter/jupyter_notebook_config.py
RUN chown jpuser /home/jpuser/run_jupyter.sh

# Set up ffmpeg to make video possible in notebook
# RUN apt-get install -y --no-install-recommends ffmpeg 

# Usermod needs to happen before using it
# the test is if I can now right in dir 
RUN usermod -u 1001 jpuser 
# See https://stackoverflow.com/questions/29245216/write-in-shared-volumes-docker
USER jpuser
RUN chmod u+x /home/jpuser/run_jupyter.sh

ENV PATH /opt/conda/bin:$PATH

# ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR "/home/jpuser"
CMD [ "/bin/bash" ]
