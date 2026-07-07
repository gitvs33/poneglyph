package com.poneglyph.poneglyph

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.poneglyph/pdf_thumbnail"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getThumbnail") {
                val path = call.argument<String>("path")
                val page = call.argument<Int>("page") ?: 0
                val width = call.argument<Int>("width") ?: 300
                val height = call.argument<Int>("height") ?: 400

                if (path == null) {
                    result.error("INVALID_ARG", "path is null", null)
                    return@setMethodCallHandler
                }

                val thumb = renderPdfThumbnail(path, page, width, height)
                if (thumb != null) {
                    result.success(thumb)
                } else {
                    result.error("RENDER_FAILED", "Could not render PDF page", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun renderPdfThumbnail(
        path: String,
        pageIndex: Int,
        maxWidth: Int,
        maxHeight: Int
    ): ByteArray? {
        return try {
            val file = File(path)
            if (!file.exists()) return null

            val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            val renderer = PdfRenderer(fd)

            if (pageIndex >= renderer.pageCount) {
                renderer.close()
                fd.close()
                return null
            }

            val page = renderer.openPage(pageIndex)
            val bitmap = Bitmap.createBitmap(
                maxWidth,
                maxHeight,
                Bitmap.Config.ARGB_8888
            )
            bitmap.eraseColor(android.graphics.Color.WHITE)

            page.render(
                bitmap,
                null,          // destClip — null = whole bitmap
                null,          // transform — null = none
                PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY
            )
            page.close()

            val baos = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            bitmap.recycle()

            renderer.close()
            fd.close()

            baos.toByteArray()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
