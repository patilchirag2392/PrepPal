# PrepPal – Smart Meal Planner App

**PrepPal** is a full-featured iOS application built to help students simplify weekly meal planning, manage grocery expenses, and make smarter food decisions—all powered by AI and Firebase.

---

## ✨ Features

- 🔮 **AI-Powered Meal Suggestions**  
  Generate personalized weekly meal plans based on dietary preferences and grocery budgets using a local LLM.

- 🛒 **Auto-Generated Grocery Lists**  
  Automatically compiles a grocery list from selected meals and supports manual additions and deletions.

- 💸 **Budget Tracking**  
  Set a weekly grocery budget, assign prices to items, and monitor expenses in real-time with visual indicators.

- 📖 **Custom Recipe Management**  
  Create, edit, and favorite personal recipes that can be used in the meal planner.

- 👥 **Shared Lists**  
  Collaborate with roommates or family using shared grocery lists with real-time sync.

- 👤 **Profile Settings**  
  Save and update personal information and meal preferences to customize the AI experience.

---

## 🧠 Tech Stack

| Component        | Technology                     |
|------------------|--------------------------------|
| UI               | `SwiftUI`                      |
| Architecture     | `MVVM`                         |
| Authentication   | `Firebase Auth`                |
| Database         | `Cloud Firestore`              |
| AI Integration   | `Local LLM (Ollama)`           |
| Offline Support  | `Firestore Persistent Cache`   |
| Build Tool       | `Xcode 15`, `Swift 5`          |

---

## 🔧 Installation

### Prerequisites

- Xcode 15+
- Firebase project configured
- [Ollama](https://ollama.com) installed and running with `llama2:latest` or similar model

### Setup Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/PrepPal.git
   cd PrepPal
   ```

2. **Install Pods (if using CocoaPods)**
   ```bash
   pod install
   ```

3. **Configure Firebase**
   - Add your `GoogleService-Info.plist` to the Xcode project.
   - Enable Email/Password Authentication in the Firebase Console.

4. **Run the App**
   - Open the `.xcworkspace` file in Xcode.
   - Build and run on the iOS Simulator or a physical device.

---

## 🧠 Local LLM Integration (Ollama)

PrepPal uses a locally hosted LLM (e.g., `llama2`) to generate personalized meal suggestions without internet dependency.

### Run Ollama:

If using a simulator:
```bash
ollama serve
```

If using a physical device:
```bash
ollama serve
```

**Ensure your app is using this code in LocalLLMSwift.swift file:**

If using a simulator:
```swift
let url = URL(string: "http://localhost:11434/api/generate")!
```

If using a physical device:
```swift
let url = URL(string: "http://YOUR_IP_ADDRESS:11434/api/generate")!
```

You can verify Ollama is working by visiting `http://localhost:11434` / `http://YOUR_IP_ADDRESS:11434` in your browser or using `curl`.

---

## 🚀 Future Scope

- ⏰ Meal prep reminders via push notifications  
- 🧠 Advanced AI customization (e.g., calorie tracking, nutrition filters)  
- 👥 Social features for collaborative meal planning and recipe sharing  
- 🎨 Theming and accessibility improvements  
- 🔐 Google & Apple Sign-In integration for seamless onboarding

---

## References

- [Firebase](https://firebase.google.com)  
- [Ollama](https://ollama.com)  
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)  
- [Apple Developer Tools](https://developer.apple.com)

---
