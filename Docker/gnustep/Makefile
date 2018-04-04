all: server
	@echo "You can ssh into the container with the appdev credentials (appsec is the password)"

server:
	docker build -t gnustep4.0 .
	docker create  --name gnustep_server gnustep4.0
	docker start  gnustep_server
	@echo "Server IP address:" `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  gnustep_server`