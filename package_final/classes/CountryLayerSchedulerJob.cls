public class CountryLayerSchedulerJob {
    public static void scheduleJob() {
        // Cron expression for 2:00 AM daily
        String cronExp = '0 0 2 * * ?';
        
        // Schedule the job
        System.schedule('CountryLayer Daily Update', cronExp, new CountryLayerScheduler());
    }
}