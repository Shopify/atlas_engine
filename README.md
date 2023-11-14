# Atlas Engine

This is a rails engine that is meant to provide end-to-end address validation for rails apps

## Local Setup

## Installing in your rails app

Add the engine to your gemfile
```
gem "atlas_engine", git: "https://github.com/Shopify/atlas-engine"
```

Run the following commands to install the engine in your rails app

```
bundle lock
bin/rails generate atlas_engine:install
```

## Developing in the engine

### Setup Docker

```
brew install docker
brew install docker-compose

# to setup the docker daemon
brew install colima

# to start the docker daemon
colima start --cpu 4 --memory 8`
colima ssh
  sudo sysctl -w vm.max_map_count=262144
  exit

```

Verify if docker is running: `docker info`

### Setup Rails

```
bundle install

# If you get an ssl error with puma installation run
bundle config build.puma --with-pkg-config=$(brew --prefix openssl@3)/lib/pkgconfig
```

### Setting up Elasticsearch, Mysql

```
bash setup
docker-compose up
```

Connecting to Docker services
  * for Mysql : `mysql --host=127.0.0.1 --user=user --password=changeme`
  * for Elasticsearch : `http://localhost:9200`

  _note: if you have updated any of the ports in your .env file then use those ports instead_


### Setting up db
```
rails db:setup
```

### Starting the App, Testing
  * `bin/rails server` to start the server
  * `bin/rails test` to run tests
