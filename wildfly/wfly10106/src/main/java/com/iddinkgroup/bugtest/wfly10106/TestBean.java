package com.iddinkgroup.bugtest.wfly10106;

import java.util.logging.LogManager;
import java.util.logging.Logger;

import javax.ejb.Schedule;
import javax.ejb.Singleton;
import javax.ejb.Startup;

@Startup
@Singleton
public class TestBean {
    private static final Logger logger = LogManager.getLogManager().getLogger(TestBean.class.getName());

    @Schedule(second = "*/10", minute = "*", hour = "*", persistent = false)
    void scheduledUpdate() {
        logger.info("Time is up!");
    }
}