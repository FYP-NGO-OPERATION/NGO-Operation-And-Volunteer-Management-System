#!/bin/bash
# Script to build and dispatch end-to-end integration tests to Firebase Test Lab

echo "Building Android APK for integration testing..."
pushd android
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/app_test.dart
popd

echo "Dispatching tests to Firebase Test Lab (Physical Device Matrix)..."
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=Pixel3,version=30,locale=en,orientation=portrait \
  --device model=SM-G973F,version=28,locale=en,orientation=portrait \
  --timeout 5m \
  --results-bucket=ngo_volunteer_app_test_results

echo "Tests completed successfully."
