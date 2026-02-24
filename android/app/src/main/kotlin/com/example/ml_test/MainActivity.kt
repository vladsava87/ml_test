package com.vladsava.ml_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.opencv.android.OpenCVLoader

class MainActivity : FlutterActivity() {
    private var documentProcessor: DocumentProcessor? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!OpenCVLoader.initLocal()) {
            android.util.Log.e("OpenCV", "Unable to load OpenCV!")
        } else {
            android.util.Log.d("OpenCV", "OpenCV loaded successfully!")
        }

        documentProcessor = DocumentProcessor(flutterEngine)
    }
}
