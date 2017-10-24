TOPIC=postgres-customers
ZOOKEEPER=zookeeper:2181
KAFKA=kafka:9092
CONNECT=localhost:8083
REGISTRY=registry:8081

RUNNER=direct-runner

up:
	docker-compose up

upd:
	docker-compose up -d

fup:
	docker-compose up --force-recreate

down:
	docker-compose down

postgres:
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c 'psql -U postgres postgres'

register:
	docker-compose exec postgres bash -c 'psql -U postgres postgres -c "ALTER DATABASE postgres SET search_path TO inventory;"' && \
	curl -s -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://$(CONNECT)/connectors/ -d @register-postgres.json | jq

describe:
	docker-compose exec kafka bin/kafka-topics.sh --describe --zookeeper $(ZOOKEEPER)

offset:
	docker-compose exec kafka bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list $(KAFKA) --topic $(TOPIC) --time -1

dump:
	docker-compose exec registry /usr/bin/kafka-avro-console-consumer --bootstrap-server $(KAFKA) --from-beginning --property print.key=true \
	--topic $(TOPIC) --property schema.registry.url=http://$(REGISTRY)

subjects:
	curl -s http://localhost:8081/subjects | jq

schema:
	curl -s http://localhost:8081/subjects/$(TOPIC)-value/versions/latest \
	| jq '.schema | fromjson' > src/main/avro/$(TOPIC)-value.avsc

compile:
	docker-compose run beam mvn compile

consumer:
	docker-compose run beam mvn compile exec:java -Dexec.mainClass=com.andrewjones.KafkaAvroConsumerExample -P$(RUNNER)

addcolumn:
	docker-compose exec postgres bash -c 'psql -U postgres postgres -c "ALTER TABLE customers ADD COLUMN age INT;"' && \
	docker-compose exec postgres bash -c "psql -U postgres postgres -c \"INSERT INTO customers VALUES (default,'Andrew','Jones','andrew@foobar.com', 31);\"" && \
	docker-compose restart connect

rename:
	docker-compose exec postgres bash -c 'psql -U postgres postgres -c "ALTER TABLE customers RENAME COLUMN email TO email_address;"'

clean: clean-docker clean-files

clean-docker:
	docker-compose rm -f

clean-files:
	rm wordcounts*
