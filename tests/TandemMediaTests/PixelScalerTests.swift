import CoreVideo
import XCTest
@testable import TandemMedia

final class PixelScalerTests: XCTestCase {
    func testScalingKeepsStraightAlphaColoursAndTheirMode() throws {
        try checkScale(mode: kCVImageBufferAlphaChannelMode_StraightAlpha, value: 255)
    }

    func testScalingKeepsPremultipliedAlphaColoursAndTheirMode() throws {
        try checkScale(mode: kCVImageBufferAlphaChannelMode_PremultipliedAlpha, value: 128)
    }

    func testTransparentBlackDoesNotDarkenRedAtTheScaledEdge() throws {
        var created: CVPixelBuffer?
        XCTAssertEqual(CVPixelBufferCreate(nil, 8, 8, kCVPixelFormatType_32BGRA,
            [kCVPixelBufferIOSurfacePropertiesKey: [String: Any]()] as CFDictionary, &created), kCVReturnSuccess)
        let source = try XCTUnwrap(created)
        CVBufferSetAttachment(source, kCVImageBufferAlphaChannelModeKey, kCVImageBufferAlphaChannelMode_StraightAlpha, .shouldPropagate)
        CVPixelBufferLockBaseAddress(source, [])
        let bytes = CVPixelBufferGetBaseAddress(source)!.assumingMemoryBound(to: UInt8.self)
        for y in 0..<8 { for x in 0..<8 {
            let offset = y * CVPixelBufferGetBytesPerRow(source) + x * 4
            bytes[offset] = 0; bytes[offset + 1] = 0
            bytes[offset + 2] = x < 4 ? 255 : 0
            bytes[offset + 3] = x < 4 ? 255 : 0
        } }
        CVPixelBufferUnlockBaseAddress(source, [])
        let scaled = try PixelScaler(width: 3, height: 3, pixelFormat: kCVPixelFormatType_32BGRA).scale(source)
        CVPixelBufferLockBaseAddress(scaled, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(scaled, .readOnly) }
        let pixel = CVPixelBufferGetBaseAddress(scaled)!.assumingMemoryBound(to: UInt8.self) + CVPixelBufferGetBytesPerRow(scaled) + 4
        XCTAssertGreaterThan(pixel[3], 0)
        XCTAssertLessThan(pixel[3], 255)
        XCTAssertEqual(Double(pixel[2]), 255, accuracy: 1, "partial coverage changes alpha, not the red colour")
    }

    private func checkScale(mode: CFString, value: UInt8) throws {
        var created: CVPixelBuffer?
        XCTAssertEqual(CVPixelBufferCreate(nil, 8, 8, kCVPixelFormatType_32BGRA,
            [kCVPixelBufferIOSurfacePropertiesKey: [String: Any]()] as CFDictionary, &created), kCVReturnSuccess)
        let source = try XCTUnwrap(created)
        CVBufferSetAttachment(source, kCVImageBufferAlphaChannelModeKey, mode, .shouldPropagate)
        CVBufferSetAttachment(source, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, .shouldPropagate)
        CVBufferSetAttachment(source, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, .shouldPropagate)
        CVPixelBufferLockBaseAddress(source, [])
        let bytes = CVPixelBufferGetBaseAddress(source)!.assumingMemoryBound(to: UInt8.self)
        for y in 0..<8 { for x in 0..<8 {
            let offset = y * CVPixelBufferGetBytesPerRow(source) + x * 4
            for channel in 0..<3 { bytes[offset + channel] = value }
            bytes[offset + 3] = 128
        } }
        CVPixelBufferUnlockBaseAddress(source, [])
        let scaler = try PixelScaler(width: 4, height: 4, pixelFormat: kCVPixelFormatType_32BGRA)
        let scaled = try scaler.scale(source)
        CVPixelBufferLockBaseAddress(scaled, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(scaled, .readOnly) }
        let pixel = CVPixelBufferGetBaseAddress(scaled)!.assumingMemoryBound(to: UInt8.self)
        for channel in 0..<3 { XCTAssertEqual(Double(pixel[channel]), Double(value), accuracy: 1) }
        XCTAssertEqual(pixel[3], 128)
        XCTAssertEqual(CVBufferCopyAttachment(scaled, kCVImageBufferAlphaChannelModeKey, nil) as? String, mode as String)
    }
}
