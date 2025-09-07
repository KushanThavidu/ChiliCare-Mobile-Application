$tfliteVersion = "2.12.0"
$baseUrl = "https://github.com/am15h/tflite_flutter_plugin/raw/master/example/android/app/src/main/jniLibs"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path "windows\flutter\tflite" | Out-Null

# Download files
Invoke-WebRequest -Uri "$baseUrl/x86_64/libtensorflowlite_c.so" -OutFile "windows\flutter\tflite\tensorflowlite_c.dll"

Write-Host "TensorFlow Lite files downloaded successfully!"
