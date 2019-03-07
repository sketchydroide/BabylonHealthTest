import Alamofire

struct PostListResource: Resource {
    let path: String = "/posts"
    let method: HTTPMethod = .get
}
