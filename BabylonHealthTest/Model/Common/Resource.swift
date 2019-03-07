import Alamofire

enum ResourceError: Error {
    case unableToCreateRequest
}

enum Host: String {
    case `default` = "jsonplaceholder.typicode.com"
}

enum Scheme: String {
    case secure = "https"
}

protocol Resource {
    var path: String { get }
    var host: String { get }
    var scheme: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    func makeRequest() throws -> DataRequest
}

// MARK: default values for properties
extension Resource {
    var host: String { return Host.default.rawValue }
    var scheme: String { return Scheme.secure.rawValue }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? { return nil }
}

// MARK: default implementation of makeRequest
extension Resource {
    func makeRequest() throws -> DataRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.path = path
        urlComponents.host = host

        guard let url = urlComponents.url else {
            throw ResourceError.unableToCreateRequest
        }

        return Alamofire.request(url,
                                 method: self.method,
                                 parameters: self.parameters)
    }
}
