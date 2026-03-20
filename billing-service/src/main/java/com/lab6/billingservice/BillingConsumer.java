package com.lab6.billingservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class BillingConsumer {

    private static final Logger logger = LoggerFactory.getLogger(BillingConsumer.class);

    @KafkaListener(topics = "order-topic", groupId = "billing-group")
    public void consumeOrder(String order) {
        logger.info("Billing Service received order: {}", order);
        logger.info("Invoice generated successfully for order.");
    }
}
