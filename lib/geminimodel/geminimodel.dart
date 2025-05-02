//
// import 'package:google_generative_ai/google_generative_ai.dart';
// import '../constants/api_constants.dart';
//
// class GeminiModelProvider {
//   static final GenerativeModel model = GenerativeModel(
//     model: ApiConstants.modelName,
//     apiKey: ApiConstants.apiKey,
//     generationConfig: GenerationConfig(
//       temperature: ApiConstants.temperature,
//       maxOutputTokens: ApiConstants.maxTokens,
//       topP: 1,
//       topK: 1,
//     ),
//     safetySettings: [
//       SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
//       SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
//       SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
//       SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
//     ],
//   );
// }
