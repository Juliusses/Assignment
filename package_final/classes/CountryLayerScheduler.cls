global class CountryLayerScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        CountryLayerService.updateCountryLayerData();
    }
}