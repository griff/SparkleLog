FROM ubuntu:quantal
MAINTAINER Brian Olsen "brian@maven-group.org"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl patch git ruby1.9.1-dev && apt-get clean
RUN cd /srv && git clone https://github.com/griff/buildstep.git
RUN mkdir -p /build/buildpacks
ADD . /app
RUN BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-ruby.git /srv/buildstep/stack/builder
