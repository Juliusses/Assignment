# testAssignment

Prerequisites:
- fresh trailhead sandbox  (tested on fresh trailhaead sandbox)


Manual steps - after deploy:

1. Flow Lead - Berfore Update - Track Owner Change - v1 is activated (verify)

2. Add credentials principal to System admin profile:

- System Admin profile > External Credential Principal Access > add countrylayerService - countrylayerPrincipal 
  ( recommended to find with User Management Settings > Enhanced Profile User Interface enabled )

3. Populate custom settings - credentials
- In custom settings > manage > new > countrylayerServiceCred populate access_key = [handed out in separate channel]
  
  (note:  when testing in another trailhead org, I run into a problem with adding new custom settings record, which resulted into salesforce error/failure. In this scenaro, update    apex class CountryLayerService and replace custom settings usage by hardcoded value (only for testing prpose): 
  
  // Sends HTTP request to the CountryLayer API and returns the response private 
  static HttpResponse sendHttpRequest() { Http http = new Http(); 
      HttpRequest request = new HttpRequest(); 
      request.setEndpoint('callout:countrylayerService/v2/all?access_key=[handed out in separate channel]'); 
      request.setMethod('GET'); request.setTimeout(120000); 
      HttpResponse response = http.send(request); 
      System.debug('Response Status: ' + response.getStatusCode()); return response; }

4. Initiate scheduled job:

- Initiation via apex execute anonymous window:

  CountryLayerSchedulerJob.scheduleJob(); 

  and verify if active in ScheduledJobs in setup.

- For testing purposes you can use CountryLayerScheduler for imidiate run (T+1 minute)
- Initiation via apex execute anonymous window:

  String cron = System.now().addMinutes(1).format('s m H d M \'?\' yyyy');
  System.schedule('CountryLayerServiceImmediateRun', cron, new CountryLayerScheduler());

  and verify if active in ScheduledJobs in setup.
