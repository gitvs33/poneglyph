import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private var pdfThumbnailChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - FlutterImplicitEngineDelegate

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Set up PDF thumbnail channel.
    guard let registrar = engineBridge.registrar(forPlugin: "PdfThumbnailPlugin") else { return }
    let channel = FlutterMethodChannel(
      name: "com.poneglyph/pdf_thumbnail",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handlePdfThumbnail(call: call, result: result)
    }
    pdfThumbnailChannel = channel
  }

  // MARK: - PDF Thumbnail Handler

  private func handlePdfThumbnail(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getThumbnail" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard let args = call.arguments as? [String: Any],
          let path = args["path"] as? String else {
      result(FlutterError(code: "INVALID_ARG", message: "path is null", details: nil))
      return
    }

    let pageIndex = args["page"] as? Int ?? 0
    let maxWidth = args["width"] as? Int ?? 300
    let maxHeight = args["height"] as? Int ?? 400

    guard let pngData = renderPdfThumbnail(
      path: path,
      pageIndex: pageIndex,
      maxWidth: maxWidth,
      maxHeight: maxHeight
    ) else {
      result(FlutterError(code: "RENDER_FAILED", message: "Could not render PDF page", details: nil))
      return
    }

    result(pngData as FlutterStandardTypedData)
  }

  /// Render a PDF page to PNG data using CoreGraphics.
  private func renderPdfThumbnail(
    path: String,
    pageIndex: Int,
    maxWidth: Int,
    maxHeight: Int
  ) -> Data? {
    let url = URL(fileURLWithPath: path)
    guard let document = CGPDFDocument(url as CFURL) else { return nil }

    // CGPDF pages are 1-indexed.
    let pageNumber = pageIndex + 1
    guard pageNumber >= 1,
          pageNumber <= document.numberOfPages,
          let page = document.page(at: pageNumber) else {
      return nil
    }

    let pageRect = page.getBoxRect(.mediaBox)
    let scale = min(
      CGFloat(maxWidth) / pageRect.width,
      CGFloat(maxHeight) / pageRect.height
    )
    let scaledWidth = pageRect.width * scale
    let scaledHeight = pageRect.height * scale

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let context = CGContext(
      data: nil,
      width: Int(scaledWidth),
      height: Int(scaledHeight),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: bitmapInfo
    ) else { return nil }

    context.setFillColor(UIColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))

    // Flip vertically: PDF coordinate system is bottom-left, UIKit is top-left.
    context.translateBy(x: 0, y: scaledHeight)
    context.scaleBy(x: 1.0, y: -1.0)
    context.drawPDFPage(page)

    guard let cgImage = context.makeImage() else { return nil }
    let uiImage = UIImage(cgImage: cgImage)

    return uiImage.pngData()
  }
}
