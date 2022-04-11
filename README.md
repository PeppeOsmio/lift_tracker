# Lift Tracker

A simple mobile app for iOS and Android to create workout schedules and track your workout sessions.
Made with the Flutter framework.

## Getting Started

Tap on the "+" button to create a workout schedule. Once created, tap on that schedule to start a workout session
and track your lifts (reps, weight, RPE). View all your past sessions in the history tab. An excercise database
will be added in the future with pre-made excercises and workout schedules.

## Install

You can compile the code by yourself by cloning this project if you have the Flutter SDK installed on your machine. If you don't want to compile it, there's pre-built APK files for Android in releases, one for each architecture. If you don't know which one to pick, choose the arm64 version, it will probably be the correct one for your smartphone.
Compile instructions for Android:  
  * You will need Java Development Kit 11 (JDK 11) and the Flutter SDK installed on your machine. Newer versions of JDK don't work with Flutter
  * Clone this project
  * In your terminal, `cd` into the project folder
  * Run the command `flutter clean` to delete conflicting files, if there are any
  * Run the command `flutter pub get` to download the necessary Flutter packages
  * Run the command `flutter build apk --split-per-abi` to build the APK files
  * In the project sub directory `build/app/outputs/apk/release` there will be 3 APK files
  * Choose the correct APK according to your smartphone's CPU architecture. It will probably be arm64
  * Install this APK on your phone