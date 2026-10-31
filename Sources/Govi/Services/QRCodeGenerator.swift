import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

@MainActor
public struct QRCodeGenerator {
    private static let context = CIContext()
    
    public static func generateQRCode(from string: String, size: CGFloat = 200) -> UIImage {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return UIImage()
    }
}
