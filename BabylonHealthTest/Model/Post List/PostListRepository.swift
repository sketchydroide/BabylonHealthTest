import Foundation

protocol PostListRepositoryType {
    func getPostList(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> ())
    func save(postList: [PostModel])
}

final class PostListRepository: Repository<[PostModel]>, PostListRepositoryType {
    private var postList: [PostModel] = []

    func save(postList: [PostModel]) {
        self.postList = postList
        // Don't want to read write files in the main queue
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.saveValue(value: postList)
        }
    }

    func getPostList(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> ()) {
        if postList.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                guard let postList = self.loadValue() else {
                    completionHandler(.failure(RepositoryError.failedRead))
                    return
                }
                self.postList = postList
                completionHandler(.success(postList))
            }
        } else {
            completionHandler(.success(postList))
        }
    }
}
