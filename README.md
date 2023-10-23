# atlas-engine

Prototyping for https://vault.shopify.io/gsd/projects/36689, github issue https://github.com/Shopify/address/issues/2112

## Installing in local repo (Shopify specific prototyping steps)
* In Gemfile, `gem "atlas_engine", git: "https://github.com/Shopify/atlas-engine"`
* `bundle lock`
* `bin/rails generate atlas_engine:install`

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
* Run `docker cp [your es container id]:/usr/share/elasticsearch/config/certs/ca/ca.crt .` to get a copy of the certificate
on your local machine.
  * You can find your es container id by running `docker ps`.
* Set the es certificate environment variable to point to the certificate you now have on your local machine: `export ELASTICSEARCH_CLIENT_CA_CERT=/path/to/certificate/file`
* Create an API key for your local ES by running the command
```
curl --cacert ca.crt -u elastic:changeme -X POST https://localhost:9200/_security/api_key -d "{\"name\": \"my-api-key\"}" -H "Content-type: application/json"
```
  * The response should be in the form
  ```
  {"id":"some_id","name":"my-api-key","api_key":"some_api_key","encoded":"some_encoded_key"}
  ```
* Save the encoded key with `export ELASTICSEARCH_API_KEY=some_encoded_key`
* Verify ES is setup correctly with this curl command:
```
curl --cacert $ELASTICSEARCH_CLIENT_CA_CERT -H "Authorization: ApiKey $ELASTICSEARCH_API_KEY" https://localhost:9200
```

### Setting up db
* `rails db:setup`

### Starting the App, Testing
  * `bin/rails server` to start the server
  * `bin/rails test` to run tests
