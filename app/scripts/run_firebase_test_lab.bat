@echo off
echo Building Android APK for integration testing...
cd android
call gradlew.bat app:assembleAndroidTest
call gradlew.bat app:assembleDebug -Ptarget=integration_test/app_test.dart
cd ..

echo Dispatching tests to Firebase Test Lab (Physical Device Matrix)...
call gcloud firebase test android run ^
  --type instrumentation ^
  --app build/app/outputs/apk/debug/app-debug.apk ^
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk ^
  --device model=Pixel3,version=30,locale=en,orientation=portrait ^
  --device model=SM-G973F,version=28,locale=en,orientation=portrait ^
  --timeout 5m ^
  --results-bucket=ngo_volunteer_app_test_results

echo Tests completed successfully.
