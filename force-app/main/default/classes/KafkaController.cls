public with sharing class KafkaController {

    public KafkaController(String payload) {
        //create a json object of format {msg: "some value"}
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('msg', payload);
        gen.writeEndObject();
        String message = gen.getAsString();
        //encode the payload
        payload = EncodingUtil.urlEncode(message, 'UTF-8');
        //call the static method to send the json to kafka
        String url = 'https://sfdc-ctx.herokuapp.com/api/kafka/startProducer';

        String response = submitToKafka(url, payload);
        String msg = getResponseBody(response);
        System.debug('Response: ' + response);
        System.debug('Message: ' + msg);
    }

    

    //create a static class with http get method to call a get URL
    @AuraEnabled
    public static String submitToKafka(String url, String payload) {
        String endpoint = url+'?payload='+payload;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        String response = res.getBody();
        //process the response for OK or Error
        if (res.getStatusCode() == 200) {
            return 'OK';
        } else {
            return 'Error';
        }

    }
    
    public static string getResponseBody(String response) {
        String result = '';
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'msg')) {
                parser.nextToken();
                result = parser.getText();
            }
        }
        return result;
        
    }


}