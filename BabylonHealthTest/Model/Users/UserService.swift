import Foundation

enum UserServiceError {
    case userNotFound
}

extension UserServiceError: TitledError {
    var title: String {
        return "Sorry!"
    }

    var body: String {
        switch self {
        case .userNotFound:
            return "No user was found for those details."
        }
    }
}

protocol UserServiceType {
    func fetchUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> Void)
}

struct UserService: UserServiceType {
    let requestManager: RequestManagerType
    let repository: UsersRepositoryType

    init(requestManager: RequestManagerType,
         repository: UsersRepositoryType = UsersRepository()) {
        self.requestManager = requestManager
        self.repository = repository
    }

    func fetchUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> Void) {
        let resource = UsersResource(userId: id)
        requestManager.makeNetworkCall(using: resource) { (result: Result<[UserModel]>) in
            switch result {
            case let .success(users):
                guard let user = users.first else {
                    completionHandler(.failure(UserServiceError.userNotFound))
                    return
                }
                self.repository.update(with: user)
                completionHandler(.success(user))
            case let .failure(error):
                self.repository.getUser(with: id) { (repositoryResult: Result<UserModel>) in
                    switch repositoryResult {
                    case let .success(user):
                        completionHandler(.success(user))
                    case .failure:
                        completionHandler(.failure(error))
                    }
                }
            }
        }
    }
}
