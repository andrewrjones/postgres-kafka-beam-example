package com.andrewjones;

import com.andrewjones.avro.customers;
import io.confluent.kafka.serializers.AbstractKafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import org.apache.kafka.common.serialization.Deserializer;

import java.util.Map;

public class CustomersKafkaAvroDeserializer extends AbstractKafkaAvroDeserializer implements Deserializer<customers> {
    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
        configure(new KafkaAvroDeserializerConfig(configs));
    }

    @Override
    public customers deserialize(String s, byte[] bytes) {
        return (customers) this.deserialize(bytes);
    }

    @Override
    public void close() {}
}
