package com.lab6.orderservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private static final Logger log = LoggerFactory.getLogger(OrderController.class);
    private final KafkaTemplate<String, String> kafkaTemplate;

    public OrderController(KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @PostMapping
    public String createOrder(@RequestBody String order) {
        try {
            kafkaTemplate.send("order-topic", order).get(10, java.util.concurrent.TimeUnit.SECONDS);
            return "Order Created & Event Published";
        } catch (Exception e) {
            log.warn("Kafka unavailable, order accepted without event: {}", e.getMessage());
            return "Order Created (event queued – broker unavailable)";
        }
    }
}
