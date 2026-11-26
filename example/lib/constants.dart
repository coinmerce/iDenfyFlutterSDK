const String BASE_URL = 'ivs.idenfy.com';
const String clientId = 'idenfySampleClientID';
const String apiKey = '1SRKxkH6yHH'; // PUT_YOUR_IDENFY_API_KEY_HERE
const String apiSecret =
    'UKlbxDkeY9yTqmv9UqBk'; // PUT_YOUR_IDENFY_API_SECRET_HERE

// const String iDenfyBaseUrl = 'https://ivs.idenfy.com';
// const String iDenfyClientId = 'io.coinmerce.app';
// const String iDenfyApiKey = '1SRKxkH6yHH';
// const String iDenfyApiSecret = 'UKlbxDkeY9yTqmv9UqBk';
const SdkFlow selectedFlow = SdkFlow.withImplementedColors;

enum SdkFlow {
  defaultFlow,
  withImplementedColors,
}
