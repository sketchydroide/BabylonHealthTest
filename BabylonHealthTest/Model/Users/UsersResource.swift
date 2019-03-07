import Alamofire

private enum ParameterKey: String {
    case id
}

struct UsersResource: Resource {
    let path: String = "/users"
    let method: HTTPMethod = .get
    let userId: Int?

    var parameters: Parameters? {
        guard let userId = userId else { return nil }
        return [ParameterKey.id.rawValue: userId]
    }
}
