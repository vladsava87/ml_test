package com.vladsava.ml_test

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlin.math.pow

class DocumentProcessor(flutterEngine: FlutterEngine) {
    private val channelName = "com.vladsava.ml_test/document_processing"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "processDocument" -> {
                            val imagePath = call.argument<String>("imagePath")
                            val pointsList = call.argument<List<Map<String, Double>>>("points")

                            val streamWidth = call.argument<Double>("streamWidth") ?: 0.0
                            val streamHeight = call.argument<Double>("streamHeight") ?: 0.0

                            if (imagePath != null && pointsList != null && pointsList.size == 4) {
                                executor.execute {
                                    try {
                                        val warpedBytes =
                                                processImage(
                                                        imagePath,
                                                        pointsList,
                                                        streamWidth,
                                                        streamHeight
                                                )
                                        mainHandler.post {
                                            if (warpedBytes != null) {
                                                result.success(warpedBytes)
                                            } else {
                                                result.error(
                                                        "PROCESSING_ERROR",
                                                        "Failed to warp image",
                                                        null
                                                )
                                            }
                                        }
                                    } catch (e: Exception) {
                                        mainHandler.post {
                                            result.error("PROCESS_ERROR", e.message, null)
                                        }
                                    }
                                }
                            } else {
                                result.error(
                                        "INVALID_ARGUMENTS",
                                        "Invalid arguments provided",
                                        null
                                )
                            }
                        }
                        else -> result.notImplemented()
                    }
                }
    }

    private fun processImage(
            imagePath: String,
            pointsList: List<Map<String, Double>>,
            streamWidth: Double,
            streamHeight: Double
    ): ByteArray? {
        val srcMat = org.opencv.imgcodecs.Imgcodecs.imread(imagePath)
        if (srcMat.empty()) return null

        val scaleX = if (streamWidth > 0) srcMat.cols() / streamWidth else 1.0
        val scaleY = if (streamHeight > 0) srcMat.rows() / streamHeight else 1.0

        val sorted = pointsList.sortedBy { it["y"]!! }

        val top = listOf(sorted[0], sorted[1]).sortedBy { it["x"]!! }
        val tl = top[0]
        val tr = top[1]
        val bottom = listOf(sorted[2], sorted[3]).sortedBy { it["x"]!! }
        val bl = bottom[0]
        val br = bottom[1]

        val srcPoints =
                arrayOf(
                        org.opencv.core.Point(tl["x"]!! * scaleX, tl["y"]!! * scaleY), // TL
                        org.opencv.core.Point(tr["x"]!! * scaleX, tr["y"]!! * scaleY), // TR
                        org.opencv.core.Point(br["x"]!! * scaleX, br["y"]!! * scaleY), // BR
                        org.opencv.core.Point(bl["x"]!! * scaleX, bl["y"]!! * scaleY) // BL
                )

        val widthA =
                kotlin.math.sqrt(
                        (srcPoints[2].x - srcPoints[3].x).pow(2.0) +
                                (srcPoints[2].y - srcPoints[3].y).pow(2.0)
                )
        val widthB =
                kotlin.math.sqrt(
                        (srcPoints[1].x - srcPoints[0].x).pow(2.0) +
                                (srcPoints[1].y - srcPoints[0].y).pow(2.0)
                )
        val maxWidth = kotlin.math.max(widthA, widthB).toInt()

        val heightA =
                kotlin.math.sqrt(
                        (srcPoints[1].x - srcPoints[2].x).pow(2.0) +
                                (srcPoints[1].y - srcPoints[2].y).pow(2.0)
                )
        val heightB =
                kotlin.math.sqrt(
                        (srcPoints[0].x - srcPoints[3].x).pow(2.0) +
                                (srcPoints[0].y - srcPoints[3].y).pow(2.0)
                )
        val maxHeight = kotlin.math.max(heightA, heightB).toInt()

        val dstPoints =
                arrayOf(
                        org.opencv.core.Point(0.0, 0.0),
                        org.opencv.core.Point(maxWidth.toDouble() - 1, 0.0),
                        org.opencv.core.Point(maxWidth.toDouble() - 1, maxHeight.toDouble() - 1),
                        org.opencv.core.Point(0.0, maxHeight.toDouble() - 1)
                )

        val srcMatOfPoint = org.opencv.core.MatOfPoint2f(*srcPoints)
        val dstMatOfPoint = org.opencv.core.MatOfPoint2f(*dstPoints)

        val transformMatrix =
                org.opencv.imgproc.Imgproc.getPerspectiveTransform(srcMatOfPoint, dstMatOfPoint)
        val warpedMat = org.opencv.core.Mat()
        org.opencv.imgproc.Imgproc.warpPerspective(
                srcMat,
                warpedMat,
                transformMatrix,
                org.opencv.core.Size(maxWidth.toDouble(), maxHeight.toDouble())
        )

        val enhancedMat = org.opencv.core.Mat()
        org.opencv.core.Core.convertScaleAbs(warpedMat, enhancedMat, 1.2, 10.0)
        val rgbMat = org.opencv.core.Mat()
        org.opencv.imgproc.Imgproc.cvtColor(
                enhancedMat,
                rgbMat,
                org.opencv.imgproc.Imgproc.COLOR_BGR2RGB
        )

        val bmp =
                android.graphics.Bitmap.createBitmap(
                        rgbMat.cols(),
                        rgbMat.rows(),
                        android.graphics.Bitmap.Config.ARGB_8888
                )
        org.opencv.android.Utils.matToBitmap(rgbMat, bmp)

        val stream = java.io.ByteArrayOutputStream()
        bmp.compress(android.graphics.Bitmap.CompressFormat.JPEG, 90, stream)
        val byteArray = stream.toByteArray()

        srcMat.release()
        warpedMat.release()
        enhancedMat.release()
        rgbMat.release()
        transformMatrix.release()

        return byteArray
    }
}
