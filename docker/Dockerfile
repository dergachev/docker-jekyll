FROM ubuntu:14.04
MAINTAINER Alex Dergachev <alex@evolvingweb.ca>

# update OS
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update

# support docker host running squid-deb-proxy, optionally
# If host is running squid-deb-proxy, populate /etc/apt/apt.conf.d/30proxy
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected"

# Install dependencies
RUN apt-get install -y build-essential git curl vim openssl

# Jekyll deps
RUN apt-get install -y ruby1.9.1-dev python nodejs
RUN gem install bundler 
RUN gem install jekyll

# Prevents prompt for authenticating SSH host key on each 'rake deploy' (INSECURE)
RUN mkdir -p /root/.ssh && echo "StrictHostKeyChecking no" >> /root/.ssh/config

# Install script to ensures that newly created files are 775 by default
ADD docker-umask-wrapper.sh /bin/docker-umask-wrapper.sh
RUN chmod u+x /bin/docker-umask-wrapper.sh

ADD . /srv/docker-jekyll
WORKDIR /srv/docker-jekyll

# Expose default Octopress port
EXPOSE 4000

# Run Octopress
CMD ["/bin/bash"]
