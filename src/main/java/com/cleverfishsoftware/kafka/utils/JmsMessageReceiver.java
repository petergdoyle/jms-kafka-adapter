/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.Queue;
import javax.jms.Session;
import javax.jms.TextMessage;

/**
 *
 */
public class JmsMessageReceiver implements MessageListener {

    private final ConnectionFactory factory;
    private final String queueName;
    private Connection connection = null;

    public JmsMessageReceiver(final ConnectionFactory factory, String queueName) {
        this.factory = factory;
        this.queueName = queueName;
    }

    public void startListener() throws JMSException {
        while (connection == null) {
            connection = factory.createConnection();
            connection.start();
            Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            Queue queue = session.createQueue(queueName);
            MessageConsumer consumer = session.createConsumer(queue);
            consumer.setMessageListener(this);
        }
    }

    @Override
    public void onMessage(Message message) {
        if (message instanceof TextMessage) {
            try {
                TextMessage msg = (TextMessage) message;
                String text;
                text = msg.getText();
                new KafkaMessageSender(text).send();
                System.out.printf("Message received: %s, Thread: %s%n", text, Thread.currentThread().getName());
            } catch (JMSException ex) {
                Logger.getLogger(JmsMessageReceiver.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    public void destroy() throws JMSException {
        connection.close();
    }
}
