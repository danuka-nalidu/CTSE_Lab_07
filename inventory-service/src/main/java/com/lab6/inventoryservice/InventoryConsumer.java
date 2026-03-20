package com.lab6.inventoryservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class InventoryConsumer {

    private static final Logger logger = LoggerFactory.getLogger(InventoryConsumer.class);

    @KafkaListener(topics = "order-topic", groupId = "inventory-group")
    public void consumeOrder(String order) {
        logger.info("Inventory Service received order: {}", order);
        logger.info("Stock updated successfully for order.");
    }
}
