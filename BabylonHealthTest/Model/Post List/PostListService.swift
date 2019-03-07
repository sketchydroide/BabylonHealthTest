import Foundation

protocol PostListServiceType {
    func refreshPosts(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> Void)
}

struct PostListService: PostListServiceType {
    let requestManager: RequestManagerType
    let repository: PostListRepositoryType
    let resource: PostListResource

    init(requestManager: RequestManagerType,
         resource: PostListResource = PostListResource(),
         repository: PostListRepositoryType = PostListRepository()) {
        self.requestManager = requestManager
        self.repository = repository
        self.resource = resource
    }

    func refreshPosts(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> Void) {
        requestManager.makeNetworkCall(using: resource) { (result: Result<[PostModel]>) in
            switch result {
            case let .success(postList):
                self.repository.save(postList: postList)
                completionHandler(.success(postList))
            case let .failure(networkError):
                self.repository.getPostList(onCompletion: { (repositoryResult: Result<[PostModel]>) in
                    switch repositoryResult {
                    case let .success(postList):
                        completionHandler(.success(postList))
                    case .failure:
                        completionHandler(.failure(networkError))
                    }
                })
            }
        }
    }
}
