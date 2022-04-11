# Lift Tracker

A simple mobile app for iOS and Android to create workout schedules and track your workout sessions.
Made with the Flutter framework.

## Getting Started

Tap on the "+" button to create a workout schedule. Once created, tap on that schedule to start a workout session
and track your lifts (reps, weight, RPE). View all your past sessions in the history tab. An excercise database
will be added in the future with pre-made excercises and workout schedules.

## Install

You can compile the code by yourself by cloning this project if you have the Flutter SDK installed on your machine.
If you don't want to compile it, there's a pre-built APK file for Android in releases. 
If you do choose to compile the code, clone this project and follow these steps:  
  * Clone this project
  * In your terminal, `cd` into the project folder
  * Run the command: `flutter pub get` to download the necessary Flutter packages
  * Run the command: `flutter build apk --split-per-abi` to build the apk files
  * In the project sub directory `build/app/outputs/apk/release` there will be 3 apk files
  * Choose the correct apk according to your smartphone's CPU architecture. It will probably be arm64
  * Install this apk on your phone
