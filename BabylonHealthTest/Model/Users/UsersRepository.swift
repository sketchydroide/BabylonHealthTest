import Foundation

protocol UsersRepositoryType {
    func update(with user: UserModel)
    func getUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> ())
}

final class UsersRepository: Repository<Set<UserModel>>, UsersRepositoryType {
    private var userList: Set<UserModel> = []

    func findUser(with id: Int) -> UserModel? {
        return userList.filter({ $0.id == id }).first
    }

    func update(with user: UserModel) {
        userList.update(with: user)
        // Don't want to read write files in the main queue
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.saveValue(value: self.userList)
        }
    }

    func getUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> ()) {
        if userList.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                guard let userList = self.loadValue() else {
                    completionHandler(.failure(RepositoryError.failedRead))
                    return
                }

                self.userList = userList
                guard let user = self.findUser(with: id) else {
                    completionHandler(.failure(RepositoryError.failedRead))
                    return
                }
                completionHandler(.success(user))
            }
        } else {
            guard let user = self.findUser(with: id) else {
                completionHandler(.failure(RepositoryError.failedRead))
                return
            }
            completionHandler(.success(user))
        }
    }
}
