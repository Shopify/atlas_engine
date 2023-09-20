# atlas-engine-test-one

Prototyping for https://vault.shopify.io/gsd/projects/36689, github issue https://github.com/Shopify/address/issues/2112

## Installing in local repo (Shopify specific prototyping steps)
* In Gemfile, `gem "atlas_engine_test_one", git: "https://github.com/Shopify/atlas-engine-test-one"`
* `bundle lock`
* `bin/rails generate atlas_engine_test_one:install`

## Setting up development environment
* `bundle install` to install dependencies
  * If you get an ssl error with puma installation run
    ```
    bundle config build.puma --with-pkg-config=$(brew --prefix openssl@3)/lib/pkgconfig
    ```

### Setting up Elasticsearch - MacOS ARM
* `brew install docker`.
* `brew install docker-compose`.
* `brew install colima` for the Docker Daemon.
* `colima start --cpu 4 --memory 8` to start the Docker Daemon.
* `colima ssh`
  * `sudo sysctl -w vm.max_map_count=262144`
  * `exit`
* `docker info` to ensure the daemon is running
* Run `docker-compose up` to bring up docker containers for ES and mysql.
  * To create an ES container from scratch, follow [this guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).

### Setting up db
* `rails db:setup`

### Starting the App, Testing
  * `bin/rails server` to start the server
  * `bin/rails test` to run tests
