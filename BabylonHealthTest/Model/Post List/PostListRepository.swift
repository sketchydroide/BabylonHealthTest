import Foundation

protocol PostListRepositoryType {
    func getPostList(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> Void)
    func save(postList: [PostModel])
}

final class PostListRepository: Repository<[PostModel]>, PostListRepositoryType {
    private var postList: [PostModel] = []

    func save(postList: [PostModel]) {
        self.postList = postList
        // Don't want to read write files in the main queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.saveValue(value: postList)
        }
    }

    func getPostList(onCompletion completionHandler: @escaping (_ result: Result<[PostModel]>) -> Void) {
        if postList.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
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
