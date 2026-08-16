# Newfoundland Trails App

This project makes use of the Dart programming language and Flutter its app  
package to implement an novel IOS and Android compatible app to allow users to  
explore the trails of Newfoundland and record their experiences all powered by a  
Firebase to create a user friendly platform.

## Prerequisites

Before running or configuring this project, ensure your development environment has:
* [Flutter SDK](https://flutter.dev) installed (Stable channel recommended)
* [Node.js](https://nodejs.org) installed (Required to run the Firebase CLI tool)
* A [Firebase Account](https://console.firebase.google.com/)

## Setup and Configuration

### Step 1: Install Global CLI Tools
Open your terminal and install the required command-line interfaces globally:

```bash
# Install the core Firebase CLI
npm install -g firebase-tools

# Install the FlutterFire CLI helper tool
dart pub global activate flutterfire_cli
```

### Step 2: Authenticate with Firebase
Log into your Google account associated with your Firebase console:

```bash
firebase login
```

### Step 3: Configure the Flutter App
Run the configuration command from the **root directory** of your Flutter project. This interactive script automatically registers your application for chosen platforms (iOS, Android, Web) and creates or links an existing Firebase project.

```bash
flutterfire configure
```
*Follow the on-screen terminal prompts to select or create your project.*

This process creates a dedicated `lib/firebase_options.dart` configuration file containing non-secret identifiers optimized for your selected operating systems.

## Running the Application

After initializing everything, fetch dependencies and deploy the project target to your running device or simulator:

```bash
# Get all packages
flutter pub get

# Run on available target devices
flutter run
```
