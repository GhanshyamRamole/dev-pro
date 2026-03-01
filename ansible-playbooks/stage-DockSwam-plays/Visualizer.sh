#Docker Swarm Visualizer :

#(https://github.com/dockersamples/docker-swarm-visualizer)

#To run in a docker swarm:

 docker run -it --name=viz -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer


#docker service ls
#access visualizer from webbrowser with help of manager IP
#http:192.168.1.10:8080
