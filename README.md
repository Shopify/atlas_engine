# atlas-engine-test-one

Prototyping for https://vault.shopify.io/gsd/projects/36689, github issue https://github.com/Shopify/address/issues/2112

## Setting up development environment
* `bundle install` to install dependencies

### Setting up Elasticsearch - MacOS ARM
* `brew install docker`
* `brew install colima` for the Docker Daemon
* `colima start` to start the Docker Daemon
* `colima ssh`
  * `sysctl -w vm.max_map_count=262144`
  * `exit`
* `docker info` to ensure the daemon is running
* With the above dependencies in place, follow [this guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).

### Setting up db
* `rails db:setup`

* Otherwise, the gem follows standard Rails practices:
  * `bin/rails server` to start the server
  * `bin/rails test` to run tests
