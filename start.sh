DIR=SVHN
LABEL=svhn
sudo docker kill $(sudo docker ps -q)
sudo docker build -t $LABEL .
ECHO $LABEL
sudo docker run -it -p 8888:8888 -v /home/tako/testroom/$DIR/dockervolume/:/home/jpuser/dockerhostvolume  $LABEL