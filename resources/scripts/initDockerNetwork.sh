if [ "$1" = "" ]; then
	echo "A network paremeter must be supplied"
    exit 0
fi

exists=$(sudo docker network ls | grep $1)

if [ -z $exists ]; then
	echo "Creating docker network: $1"
    sudo docker network create $1
else
	echo "$1 network running"
fi