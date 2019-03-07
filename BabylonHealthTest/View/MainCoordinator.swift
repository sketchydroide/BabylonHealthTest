import UIKit

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    let requestManager = RequestManager()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let service = PostListService(requestManager: requestManager)
        let viewModel = PostListViewModel(service: service)
        let vc = PostListViewController(viewModel: viewModel)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showAlert(for error: TitledError) {
        let alert = UIAlertController(title: error.title, message: error.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        navigationController.present(alert, animated: true)
    }
}

// MARK: PostListViewControllerDelegate
extension MainCoordinator: PostListViewControllerDelegate {
    func postListViewController(_ vc: PostListViewController, didSelectPost post: PostModel) {
        let viewModel = PostDetailViewModel(postModel: post,
                                            userService: UserService(requestManager: requestManager),
                                            commentsService: CommentsService(requestManager: requestManager))
        let vc = PostDetailViewController(viewModel: viewModel)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func postListViewController(_ vc: PostListViewController, didHaveAnError error: TitledError) {
        self.showAlert(for: error)
    }
}

// MARK: PostDetailViewControllerDelegate
extension MainCoordinator: PostDetailViewControllerDelegate {
    func postDetailViewController(_ vc: PostDetailViewController, didHaveAnError error: TitledError) {
        self.navigationController.popToRootViewController(animated: true)
        self.showAlert(for: error)
    }
}
