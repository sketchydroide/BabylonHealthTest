import Foundation
@testable import BabylonHealthTest

enum MockError: TitledError {
    case mockError
    
    var body: String {
        return "Mock Error"
    }
}

final class PostListServiceMock: PostListServiceType {
    var mockError: TitledError?
    var mockPostList: [PostModel] = []
    
    func refreshPosts(onCompletion completionHandler: @escaping (Result<[PostModel]>) -> ()) {
        if let error = mockError {
            completionHandler(.failure(error))
        } else {
            completionHandler(.success(mockPostList))
        }
    }
}
