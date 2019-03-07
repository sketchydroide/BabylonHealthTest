import Foundation

protocol CommentsRepositoryType {
    func update(with comments: [CommentModel])
    func getComments(for postId: Int, onCompletion completionHandler: @escaping (_ result: Result<[CommentModel]>) -> Void)
}

final class CommentsRepository: Repository<Set<CommentModel>>, CommentsRepositoryType {
    private var commentsList: Set<CommentModel> = []
    
    func findComments(for postId: Int) -> [CommentModel] {
        return commentsList.filter({ $0.postId == postId })
    }
    
    func update(with comments: [CommentModel]) {
        commentsList.formUnion(comments)
        // Don't want to read write files in the main queue
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            self.saveValue(value: self.commentsList)
        }
    }
    
    // This method will try to get comments for a certain post id, but finding no comments for that post
    // is no reason to give back an error, since that post might not have any comments
    func getComments(for postId: Int, onCompletion completionHandler: @escaping (_ result: Result<[CommentModel]>) -> Void) {
        if commentsList.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                guard let commentsList = self.loadValue() else {
                    completionHandler(.failure(RepositoryError.failedRead))
                    return
                }
                self.commentsList = commentsList
                completionHandler(.success(self.findComments(for: postId)))
            }
        } else {
            completionHandler(.success(findComments(for: postId)))
        }
    }
}
