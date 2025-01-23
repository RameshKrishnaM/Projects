package com.example.biomatricpro
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricPrompt.AuthenticationCallback
import androidx.biometric.BiometricPrompt.PromptInfo
import android.util.Log 
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.biomatricpro"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "storeFingerprint") {
                // Implement fingerprint storage logic here
                val stored = storeFingerprintData()
                result.success(stored)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun storeFingerprintData(): Boolean {
        // Create a BiometricPrompt instance
        val biometricPrompt = BiometricPrompt(this, mainExecutor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    // Authentication successful, store fingerprint data
                    // You can generate a token or identifier to represent the fingerprint
                    val fingerprintToken = generateFingerprintToken()
                    // Store the fingerprint token securely, such as in SharedPreferences or encrypted database
                    saveFingerprintToken(fingerprintToken)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    // Authentication error, handle accordingly
                    Log.e("BiometricPrompt", "Authentication error: $errorCode - $errString")
                }
            })

        // Create a PromptInfo instance
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authenticate to store fingerprint data")
            .build()

        // Authenticate the user with BiometricPrompt
        biometricPrompt.authenticate(promptInfo)

        // Return true indicating that the storage logic was initiated
        return true
    }

    private fun generateFingerprintToken(): String {
        // Simulate generating a unique token based on fingerprint data
        // In a real application, this would involve cryptographic hashing or other secure techniques
        val fingerprintData = "raw_fingerprint_data" // Replace this with the actual fingerprint data
        val hashedData = hashFingerprintData(fingerprintData)
        return hashedData
    }
    
    private fun hashFingerprintData(fingerprintData: String): String {
        // Implement cryptographic hashing algorithm (e.g., SHA-256) to generate a hash from fingerprint data
        // For demonstration purposes, return a simple hash using Kotlin's hashCode() method
        return fingerprintData.hashCode().toString()
    }
    

    private fun saveFingerprintToken(token: String) {
        // Implement fingerprint token storage logic here
        // For demonstration purposes, print the token to Logcat
        Log.d("FingerprintToken", "Fingerprint token: $token")
    }
    
}
