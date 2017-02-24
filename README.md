# puppet-docker

[![Build Status](https://travis-ci.org/teneleven/puppet-docker.svg?branch=master)](https://travis-ci.org/teneleven/puppet-docker)

This module is fairly complex. Here are some examples to help get you started.
**NOTE**: one should only use this module in a *dev* environment - little
thought has been given to security. *Use on production at your own risk*.

Example hiera.yaml:

```yaml
docker:
  provision:
    # This block uses a bit of magic in order to simplify docker-compose setup of multiple sites.
    #
    # First, it checks if the hash key exists in apps/KEY - if so, it uses the services.yaml there.
    # Then, it checks if the hash value exists in apps/VALUE - if so, it uses the services.yaml there.
    # As a fallback, it checks if apps/default/VALUE exists - if so, it uses the services.yaml there.
    # Otherwise, it uses apps/default/services.yaml as a default.
    #
    # This ALWAYS sets the COMPOSE_APP_TYPE env variable to the hash VALUE. This way, with all this combined, we can
    # easily extend the docker-compose/default.yml file if necessary, setting APP_TYPE to the value.
    #
    # If doubtful on what to use, just set the KEY to your app name (which has a corresponding /var/www/KEY directory),
    # and VALUE to your app type (which has a corresponding apps/default/VALUE/services.yaml file). If you're going
    # fully custom, just ensure there's a apps/KEY directory and it will use the services.yaml file there (no magic
    # other than initial puppet provision).
    symfonysite: 'symfony'
    lamp: 'lamp'

  params:
    docker_prefix: '1011'
    default_hosts: ['${project_name}.docker']

    compose_file: "services.yaml"
    compose_default: "services.yaml"
    compose_dir: "%{::volume_dir}/devops/apps"
    compose_fallback_dir: "%{::volume_dir}/devops/apps/default"

  run:
    - proxy

  images:
    - 'base:16.04'
    - mysql

  containers:
    proxy:
      image: 'jwilder/nginx-proxy'
      volumes: ["%{::volume_dir}/www:/var/www", '/var/run/docker.sock:/tmp/docker.sock:ro', '/etc/nginx/vhost.d', '/etc/nginx/sites-available', '%{::volume_dir}/devops/ssl-certs:/etc/nginx/certs']
      expose: ['80', '443']
      ports:  ['80:80', '443:443']
    'base:16.04':
      ensure: 'latest'
      docker_dir: 'docker/base/16.04'
      image: 'base'
      image_tag: '16.04'
```

Example provision.pp:

```puppet
node my-laptop {
  /* provision apps & other docker stuff */
  $docker = hiera_hash('docker', {})

  create_resources('class', { '::dockerbridge::params' => $docker['params'] })
  create_resources('class', { '::dockerbridge' => delete($docker, 'params') })
}
node default {
  /* provision server setup */
  $server = hiera_hash('server', {})
  if (!empty($server)) {
    create_resources('class', { server => $server })
  }

  if ($::is_container) {

    $lamp = hiera_hash('lamp', {})
    if (!empty($lamp)) {
      create_resources('class', { '::lamp' => $lamp })
    }

    include dockerbridge

  } else {
    notice("No node definition found for ${::hostname}")
  }
}
```

Example provision.sh:

```sh
#!/bin/sh

if [ -z "$FACTER_puppet_dir" ]; then
    export FACTER_puppet_dir="$(pwd)/puppet"
fi

if [ -z "$FACTER_volume_dir" ]; then
    if [ -d "$(pwd)/volumes" ]; then
        export FACTER_volume_dir="$(pwd)/volumes"
    elif [ -d /var/volumes ]; then
        export FACTER_volume_dir=/var/volumes
    elif [ -d /volumes ]; then
        export FACTER_volume_dir=/volumes
    fi
fi

if ! [ -z "$1" ]; then
    export FACTER_hostname="$1"
fi

# detect if we get future parser (for iterators)
if [ `puppet --version | cut -c1` -eq "3" ]; then
    EXTRA_ARGS="--parser=future"
else
    EXTRA_ARGS=""
fi

# detect manifest location
if [ -f "$FACTER_puppet_dir/manifests/provision.pp" ]; then
    MANIFEST_DIR="$FACTER_puppet_dir/manifests/provision.pp"
else
    MANIFEST_DIR="$FACTER_puppet_dir/manifests"
fi

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

puppet apply \
  --modulepath "$FACTER_puppet_dir/modules"      \
  --hiera_config "$FACTER_puppet_dir/hiera.yaml" \
  $EXTRA_ARGS                                    \
  $MANIFEST_DIR;
```

Example services.yaml:

```yaml
# base docker-compose file for LAMP sites:
version: '2'
services:
  # base web container, provisioned using puppet:
  web:
    image: base:16.04
    command: 'supervisord -n'
    network_mode: bridge
    ports: ['80', '443']
    volumes:
      - /var/www/${COMPOSE_PROJECT_NAME}:/var/www
      - ../../puppet:/puppet
      - ../:/apps
    volumes_from: ['mysql-data']
    environment:
      # set application name (for URLs, and uses apps/PROJECT_NAME/*.yaml):
      - "FACTER_project_name=${COMPOSE_PROJECT_NAME}"
      # set application type (uses apps/default/APP_TYPE/*.yaml):
      - "FACTER_app_type=${COMPOSE_APP_TYPE}"
      # set application hosts (TODO this is a WIP):
      - "FACTER_app_hosts=${COMPOSE_APP_HOSTS}"
      # this is necessary so we properly manage container services:
      - FACTER_is_container=1
      # set vhost for nginx-proxy:
      - "VIRTUAL_HOST=${COMPOSE_APP_HOSTS}"

  # DB:
  mysql:
    image: mysql
    environment: ['MYSQL_ROOT_PASSWORD=123']
    network_mode: 'service:web'
    volumes_from: ['mysql-data']

  # data containers:
  mysql-data:
    image: mysql
    command: 'true'
    volumes:
      - /var/lib/mysql
      - /var/run/mysqld
```

Finally, the docker/base/16.04/Dockerfile:

```Dockerfile
FROM ubuntu:16.04

#Optional, update mirrors speedups updates, but some mirrors sometimes fail
#RUN sed -i -e 's,http://[^ ]*,mirror://mirrors.ubuntu.com/mirrors.txt,' /etc/apt/sources.list

#enable multiverse repo
# RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt $(lsb_release -cs) multiverse" >> /etc/apt/sources.list

#install required packages
RUN apt-get update --fix-missing && apt-get install -y \
        apt-utils \
        curl \
        wget \
        nfs-common \
        apt-transport-https \
        lxc \
        supervisor

# Puppet
RUN wget http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb -O /tmp/puppetlabs-release-stable.deb && \
    dpkg -i /tmp/puppetlabs-release-stable.deb && \
    apt-get update && \
    apt-get install puppet puppet-common virt-what lsb-release  -y --force-yes && \
    gem install hiera && \
    rm -f /tmp/*.deb

# help puppet-php by tricking it into thinking we have upstart
RUN mv /sbin/initctl /sbin/oldinitctl && \
    echo '#!/bin/bash\nif [ "$1" == "--version" ]\nthen\n  echo "initctl (upstart 1.12.1)"\nfi\n/sbin/oldinitctl "$@"' > /sbin/initctl && \
    chmod 755 /sbin/initctl

# gen utf-8 locale
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales

VOLUME /puppet
COPY   provision.sh /provision.sh

WORKDIR /

# simple puppet apply command & supervisor to keep container running
CMD supervisord -n
```

For documentation on the config.yaml file, please check
[puppet-lamp](https://github.com/teneleven/puppet-lamp) and
[puppet-server](https://github.com/teneleven/puppet-server).

If you successfully setup all of the above files, then running the
"provision.sh" command should provision a new symfony site at
"http://symfonysite.docker" and a new lamp site at "http://lamp.docker".
