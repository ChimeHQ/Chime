public enum ServiceProviderError: Error {
    case invalidURL
    case unableToComputeSourceLocation
    case unableToTransformValue
    case unableToTransformRange
    case noValue
    case staleDocumentState
    case unsupported
    case serviceUnavailable
    case stateInvalid
    case invalidData(String)
    case serviceFailure(Error)
}

public typealias ServiceProviderResult<T> = Result<T, ServiceProviderError>
