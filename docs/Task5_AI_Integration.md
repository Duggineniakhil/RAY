# Task 5: AI Integration Planning

## 1. Feature Purpose
Given the fast-paced, highly-visual nature of a short video application, traditional touch navigation can sometimes be a friction point for accessibility. The goal of the AI Integration is to implement a **Voice-First Navigation Assistant**. This allows users to control the application ecosystem entirely hands-free.

## 2. Core Technologies
- `speech_to_text`: Flutter plugin for utilizing device-native speech recognition algorithms (Google Assistant/Siri engines) to transcribe user audio to text strings.
- `flutter_tts`: Text-To-Speech engine to provide auditory feedback directly to the user to confirm AI actions.
- `string_similarity`: For fuzzy matching voice commands to system intents.

## 3. System Architecture
The AI layer operates as a globally accessible Riverpod `StateNotifier`. It actively listens via the microphone in a background thread while the overlay UI pulses to indicate active listening.

**The pipeline:**
1. **Trigger:** User taps the floating AI microphone button.
2. **STT:** `speech_to_text` converts the spoken phrase into a transcript.
3. **Intent Parsing:** A custom NLP matching algorithm identifies trigger keywords (e.g., "next", "scroll down", "search for cats", "go home").
4. **Action Dispatch:** The AI state manager triggers `go_router` context pushes or `PageController` animations directly.
5. **TTS (Optional):** The `flutter_tts` engine casually confirms the action (e.g., voicing "Scrolling down").

## 4. Planned Command Handlers
| Spoken Intent | Application Action |
| ------------- | ------------------ |
| "Next", "Scroll down" | Animates the main feed's PageController to `index + 1`. |
| "Like this", "Heart it" | Triggers the like animation and updates Firestore repo. |
| "Go to profile", "My account" | Executes `context.go('/home/profile')`. |
| "Search for [X]" | Navigates to Explore screen and injects [X] into the query parameters. |

This AI Module fundamentally shifts the user UX from passive scrolling to interactive command-based browsing.
