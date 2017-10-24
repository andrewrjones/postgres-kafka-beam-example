# Investigating reading from Postgres with Apache Kafka and Apache Beam

Dependencies:
* Docker (tested on Mac)
* jq

The following data is in Postgres: https://github.com/debezium/docker-images/blob/master/examples/postgres/0.6/inventory.sql

* Start all services
    * `make up`
* Register Postgres with Connect
    * `make register`
* Ensure topic has been created
    * `make describe`
* Ensure data in topic
    * `make offset`
    * `make dump`
* Download Avro schema. Saves it to `src/main/avro` and will be compiled with Maven
    * `make schema`
* Compile Avro schema
    * `make compile`
* Consume messages and run wordcount with Beam
    * `make consumer`
* Check output
    * `cat wordcount*`
* Add a new column to the table
    * `make addcolumn`
* Consumer will still run, using the old schema
    * `make consumer`
* Stop all services
    * `make down`
* Clean up
    * `make clean`
