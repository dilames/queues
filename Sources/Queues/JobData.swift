/// Holds information about the Job that is to be encoded to the persistence store.
public struct JobData: Codable {
    /// The job data to be encoded.
    public let payload: [UInt8]
    
    /// The maxRetryCount for the `Job`.
    public let maxRetryCount: Int

    /// The number of attempts made to run the `Job`.
    public let attempts: Int?
    
    /// A date to execute this job after
    public let delayUntil: Date?
    
    /// The date this job was queued
    public let queuedAt: Date
    
    /// The name of the `Job`
    public let jobName: String
    
    /// Creates a new `JobStorage` holding object
    public init(
        payload: [UInt8],
        maxRetryCount: Int,
        jobName: String,
        delayUntil: Date?,
        queuedAt: Date,
        attempts: Int = 0
    ) {
        self.payload = payload
        self.maxRetryCount = maxRetryCount
        self.jobName = jobName
        self.delayUntil = delayUntil
        self.queuedAt = queuedAt
        self.attempts = attempts
    }
}
