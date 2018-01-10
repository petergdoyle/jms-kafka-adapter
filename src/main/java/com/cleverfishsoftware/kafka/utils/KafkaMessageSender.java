/*
 */
package com.cleverfishsoftware.kafka.utils;

/**
 *
 */
public class KafkaMessageSender {

    final private String msg;

    public KafkaMessageSender(String msg) {
        this.msg = msg;
    }

    public void send() {
        System.out.println(msg);
    }
}
