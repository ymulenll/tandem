import AVFoundation
import XCTest
@testable import TandemMedia

final class MattePipelineShutdownTests: TempFolderTestCase {
    private final class HeldFrame: MatteFrameProcessing, @unchecked Sendable {
        let entered: XCTestExpectation
        let release = DispatchSemaphore(value: 0)
        init(entered: XCTestExpectation) { self.entered = entered }
        func matte(for frame: CVPixelBuffer) -> [UInt8]? {
            entered.fulfill()
            release.wait()
            return nil
        }
    }

    func testStopWaitsForAnInFlightFrameBeforeReturning() async throws {
        let source = file("camera.mov")
        try await SyntheticMedia.writeMovie(to: source, .init(width: 32, height: 32, duration: 0.1, audio: nil))
        let reader = try await VideoFrameReader(url: source)
        let entered = expectation(description: "worker has a frame")
        let processor = HeldFrame(entered: entered)
        let pipeline = try MattePipeline(reader: reader, width: 32, height: 32, settings: .standard, workers: 1, processorFactory: { processor })
        pipeline.start(qos: .userInitiated)
        await fulfillment(of: [entered], timeout: 3)
        let stopping = expectation(description: "stop called")
        let returnedEarly = expectation(description: "stop must not return while processing")
        returnedEarly.isInverted = true
        let finished = expectation(description: "stop finished")
        Thread {
            stopping.fulfill()
            pipeline.stop()
            returnedEarly.fulfill()
            finished.fulfill()
        }.start()
        await fulfillment(of: [stopping], timeout: 3)
        await fulfillment(of: [returnedEarly], timeout: 0.1)
        processor.release.signal()
        await fulfillment(of: [finished], timeout: 3)
        reader.cancel()
    }
}
