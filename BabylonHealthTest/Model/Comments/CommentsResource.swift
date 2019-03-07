import Alamofire

private enum ParameterKey: String {
    case postId
}

struct CommentsResource: Resource {
    let path: String = "/comments"
    let method: HTTPMethod = .get
    let postId: Int?

    var parameters: Parameters? {
        guard let postId = postId else { return nil }
        return [ParameterKey.postId.rawValue: postId]
    }
}
