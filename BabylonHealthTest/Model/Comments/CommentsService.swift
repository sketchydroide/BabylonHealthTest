import Foundation

protocol CommentsServiceType {
    func fetchComments(for postId: Int, onCompletion completionHandler: @escaping (_ result: Result<[CommentModel]>) -> ())
}

struct CommentsService: CommentsServiceType {
    let requestManager: RequestManagerType
    let repository: CommentsRepositoryType

    init(requestManager: RequestManagerType,
         repository: CommentsRepositoryType = CommentsRepository()) {
        self.requestManager = requestManager
        self.repository = repository
    }

    func fetchComments(for postId: Int, onCompletion completionHandler: @escaping (_ result: Result<[CommentModel]>) -> ()) {
        let resource = CommentsResource(postId: postId)
        requestManager.makeNetworkCall(using: resource) { (result: Result<[CommentModel]>) in
            switch result {
            case let .success(commentsList):
                self.repository.update(with: commentsList)
                completionHandler(.success(commentsList))
            case let .failure(error):
                self.repository.getComments(for: postId) { (repositoryResult: Result<[CommentModel]>) in
                    switch repositoryResult {
                    case let .success(commentsList):
                        completionHandler(.success(commentsList))
                    case .failure:
                        completionHandler(.failure(error))
                    }
                }
            }
        }
    }
}
