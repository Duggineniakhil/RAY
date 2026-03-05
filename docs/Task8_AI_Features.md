# Task 8: AI Features Implementation

## 1. Feature Architecture
The `VoiceAssistantService` and `VoiceNavigationOverlay` introduce highly advanced hands-free application operation utilizing the device's native AI speech transcription engines.

## 2. NLP Pipeline
The feature relies on continuous audio stream decoding executed asynchronously across the `speech_to_text` and `flutter_tts` frameworks.

- **Initialization:** At application launch, the microphone hardware status is validated, checking specifically for `Permission.microphone`.
- **Transcribing:** `speech_to_text` opens an active listening session. Words spoken by the user are transcribed instantly into Strings in real-time. Action triggers upon detecting a silence gap.
- **Intent Resolution:** Uses `FuzzyStringMatcher` and `RegExp` rulesets to translate natural phrasing (e.g., "Take me to my profile", "Go home", "Scroll up", "Search for travel") into rigid programmatic enum `ActionTypes`.

## 3. Triggering State Changes
Once an intent is mapped, the AI engine directly communicates with the root Riverpod providers or the global `AppRouter` context object.

- **Scrolling:** The Voice Assistant locates the `PageController` controlling the active Video Feed and triggers `controller.nextPage()`, smoothly scrolling to the subsequent video without user touch.
- **Like Dispatch:** If the "Like this video" intent triggers, the service synthetically executes the same Riverpod provider toggle function bound to the UI double-tap gesture.
- **Searching:** Extracts the targeted keyword from the transcription stack (e.g. isolating "cats" from "search for cats") and actively passes the string as a path parameter into the GoRouter push operation for `/home/explore`.

## 4. Audio Feedback (TTS)
To make the AI feel responsive rather than robotic, `flutter_tts` initiates conversational callbacks upon completing actions, dynamically confirming operations ("Okay, scrolling down", "Heading to your profile").
