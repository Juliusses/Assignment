@isTest
public class CountryLayerSchedulerJobTest {
    @testSetup
    static void setup() {
        // Any setup logic for other records or data can go here if needed
    }

    @isTest
    static void testScheduleJob() {
        Test.startTest();
        
        // Call the method to schedule the job
        CountryLayerSchedulerJob.scheduleJob();
        
        // Verify that the job was scheduled
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                   FROM CronTrigger WHERE CronJobDetail.Name = 'CountryLayer Daily Update'];
        
        System.assertNotEquals(null, cronTrigger, 'The scheduled job should be created');
        System.assertEquals('0 0 2 * * ?', cronTrigger.CronExpression, 'Cron expression should match the expected value');
        
        Test.stopTest();
    }

    @isTest
    static void testJobExecution() {
        // Schedule the job to run
        String cronExp = '0 0 2 * * ?';
        CountryLayerScheduler scheduler = new CountryLayerScheduler();
        String jobId = System.schedule('Test CountryLayer Job', cronExp, scheduler);

        // Use Test.startTest and Test.stopTest to simulate job execution
        Test.startTest();
        
        // Simulate the execution of scheduled jobs
        System.schedule('TestCountryLayerJob', cronExp, scheduler);
        Test.stopTest();
        
        // Verify the job ran by checking the debug logs or assertions within CountryLayerService
        // Depending on the implementation of CountryLayerService, additional verifications can be done
    }
}