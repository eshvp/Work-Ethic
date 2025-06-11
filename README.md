# Work Ethic

**Work Ethic** is a task management app built with Flutter to help improve productivity and track your work or project time through time-based task tracking.

## Features

* Create and manage tasks
* Track time spent on each task with work sessions
* Set estimated completion times for tasks
* View progress based on time spent vs. estimated time
* Mark tasks as complete
* Add detailed descriptions to tasks
* View statistics like average session time and total time committed
* Local data persistence to save your tasks between sessions
* Clean and intuitive user interface

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/workethic.git
   cd workethic
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```
3. Run the app in debug mode:

   ```bash
   flutter run
   ```
4. Build for release:

   * Android:

     ```bash
     flutter build apk --release
     ```
   * iOS:

     ```bash
     flutter build ios --release
     ```

## Building and Installing

### Android

```bash
flutter build apk --release
flutter install
```

### iOS

```bash
flutter build ios --release
```

> **Note:** iOS builds require a macOS system with Xcode installed.

## Technologies Used

* Flutter – UI framework
* Dart – Programming language
* SharedPreferences – Local storage
* Google Fonts – Typography
* UUID – Unique ID generation for tasks

## App Structure

* `models/` – Data models
* `screens/` – UI screens
* `services/` – Service and business logic

## About

Work Ethic helps you stay organized and focused by tracking both your tasks and the time you spend on them. Set estimated completion times and track your progress as you work, helping you build better time management skills and a stronger work ethic.
