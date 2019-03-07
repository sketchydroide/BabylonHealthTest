enum NetworkError {
    case noData
    case unknownError
    case decoding(Error)
    case request(Error)
    case resource(Error)
}

extension NetworkError: TitledError {
    var body: String {
        switch self {
        case .decoding:
            return "There was an error parsing the answer"
        case .noData:
            return "No data was returned"
        case .resource:
            return "Failed to attempt call the service"
        case .request:
            return "Failed the service request"
        default:
            return "There was an issue with the service"
        }
    }

    var title: String {
        return "Network Error!"
    }
}
