# CHAT-E - Multi-Agent Chatbot iOS App

A production-ready iOS chatbot application with multi-agent routing capabilities.

## Features

- **Chat Interface**: Smooth, responsive UI with message bubbles (user vs AI differentiation)
- **Multi-Agent System**: Three specialized AI agents - Coder, Writer, and General Assistant
- **Secure API Key Storage**: Uses iOS Keychain Services for secure credential storage
- **OpenAI Integration**: Ready for ChatGPT API integration
- **iOS 12+ Support**: Compatible with iPhone 5s through iPhone X

## Project Structure

```
CHAT-E/
├── CHAT-E.xcodeproj/
├── CHAT-E/
│   ├── App/
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── Message.swift
│   │   ├── Agent.swift
│   │   ├── APIRequest.swift
│   │   └── APIResponse.swift
│   ├── Views/
│   │   ├── MessageCell.swift
│   │   ├── ChatInputView.swift
│   │   └── AgentSelectorView.swift
│   ├── Controllers/
│   │   └── ChatViewController.swift
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── APIEndpoint.swift
│   │   └── APIError.swift
│   ├── Managers/
│   │   ├── KeychainManager.swift
│   │   ├── AgentRouter.swift
│   │   └── Configuration.swift
│   └── Resources/
│       ├── Info.plist
│       ├── Configuration.plist
│       ├── LaunchScreen.storyboard
│       └── Assets.xcassets/
└── .github/workflows/
    └── build.yml
```

## Setup Instructions

### 1. Prerequisites

- Xcode 10.2+
- iOS Deployment Target: iOS 12.0
- Swift 5.0+

### 2. Configuration

1. **Edit Configuration.plist** with your API settings:
   - `APIBaseURL`: Your API endpoint (default: `https://api.openai.com`)
   - `DefaultModel`: Model to use (e.g., `gpt-3.5-turbo`, `gpt-4`)

2. **Add API Key** (Choose one method):

   **Method A - Keychain (Recommended)**:
   ```swift
   // In your app, call this once to save the API key:
   KeychainManager.shared.saveAPIKey("your-api-key-here")
   ```

   **Method B - Configuration.plist** (Not recommended for production):
   Add your API key directly to Configuration.plist

### 3. Build & Run

1. Open the project in Xcode: `open CHAT-E.xcodeproj`
2. Select a simulator (e.g., iPhone X)
3. Press Cmd+R to build and run

## Architecture

### Multi-Agent System

The app uses a router-based architecture:

- **AgentType enum**: Defines three agents (coder, writer, general)
- **AgentRouter**: Routes user queries to the appropriate agent based on selection
- **System Prompts**: Each agent has a specialized system prompt defining its behavior

### Network Layer

- **APIClient**: Singleton for making API requests
- **URLSession**: Manages network calls with proper timeout handling
- **Error Handling**: Custom APIError enum for graceful error handling

### Security

- **KeychainManager**: Uses iOS Keychain Services for secure API key storage
- **No Hardcoded Keys**: API key is stored securely, never in source code
- **.gitignore**: Configuration.plist is ignored to prevent accidental commits

## Usage

1. Launch the app
2. Select an AI agent using the segmented control (Coder, Writer, or General)
3. Type a message in the input field
4. Tap the send button
5. Wait for the AI response

## Technical Details

### UI Framework
- **UIKit** (Programmatic, no Storyboards)
- **Auto Layout** using NSLayoutConstraint
- **Safe Area** handling for iPhone X notch

### Supported Devices
- iOS 12.0+
- iPhone 5s to iPhone X

### Dependencies
- None required (pure UIKit implementation)

## Build IPA

The project includes `.github/workflows/build.yml` for automatic builds:

1. Push to GitHub
2. GitHub Actions will build the IPA automatically
3. Download from Actions tab

## License

MIT License