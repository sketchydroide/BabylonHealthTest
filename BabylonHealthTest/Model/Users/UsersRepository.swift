import Foundation

protocol UsersRepositoryType {
    func update(with user: UserModel)
    func getUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> Void)
}

final class UsersRepository: Repository<Set<UserModel>>, UsersRepositoryType {
    private var userList: Set<UserModel> = []

    func findUser(with id: Int) -> UserModel? {
        return userList.filter({ $0.id == id }).first
    }

    func update(with user: UserModel) {
        userList.update(with: user)
        // Don't want to read write files in the main queue
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            self.saveValue(value: self.userList)
        }
    }

    func getUser(with id: Int, onCompletion completionHandler: @escaping (_ result: Result<UserModel>) -> Void) {
        if userList.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
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
