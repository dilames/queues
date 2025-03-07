#if compiler(>=5.5) && canImport(_Concurrency)
import Queues
import Vapor
import XCTVapor
import XCTQueues
@testable import Vapor
import NIOConcurrencyHelpers

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class AsyncQueueTests: XCTestCase {
    func testAsyncJob() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.queues.use(.test)
        
        let promise = app.eventLoopGroup.next().makePromise(of: Void.self)
        app.queues.add(MyAsyncJob(promise: promise))
        
        app.get("foo") { req in
            req.queue.dispatch(MyAsyncJob.self, .init(foo: "bar"))
                .map { _ in "done" }
        }
        
        try app.testable().test(.GET, "foo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "done")
        }
        
        XCTAssertEqual(app.queues.test.queue.count, 1)
        XCTAssertEqual(app.queues.test.jobs.count, 1)
        let job = app.queues.test.first(MyAsyncJob.self)
        XCTAssert(app.queues.test.contains(MyAsyncJob.self))
        XCTAssertNotNil(job)
        XCTAssertEqual(job!.foo, "bar")
        
        try app.queues.queue.worker.run().wait()
        XCTAssertEqual(app.queues.test.queue.count, 0)
        XCTAssertEqual(app.queues.test.jobs.count, 0)
        
        try XCTAssertNoThrow(promise.futureResult.wait())
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
struct MyAsyncJob: AsyncJob {
    let promise: EventLoopPromise<Void>
    
    struct Data: Codable {
        var foo: String
    }
    
    func dequeue(_ context: QueueContext, _ payload: Data) async throws {
        promise.succeed(())
        return
    }
}
#endif
