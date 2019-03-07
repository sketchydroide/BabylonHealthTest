import RxSwift
import UIKit

protocol PostListViewControllerDelegate: class {
    func postListViewController(_ vc: PostListViewController, didHaveAnError error: TitledError)
    func postListViewController(_ vc: PostListViewController, didSelectPost post: PostModel)
}

final class PostListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    
    private let viewModel: PostListViewModelType
    private let disposeBag = DisposeBag()
    private var currentPostList: [PostModel] = []
    
    weak var delegate: PostListViewControllerDelegate?
    
    init(viewModel: PostListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadPosts()
        title = viewModel.title
        bind(with: viewModel)
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        tableView.delegate = self
    }
    
    private func bind(with viewModel: PostListViewModelType) {
        viewModel.asynStateObservable
            .subscribe(onNext: { state in
                DispatchQueue.main.async {
                    switch state {
                    case .loading:
                        self.showLoading()
                    case let .failed(error):
                        self.hideLoading()
                        self.delegate?.postListViewController(self, didHaveAnError: error)
                    case let .content(postList):
                        self.hideLoading()
                        self.updateTable(using: postList)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func updateTable(using list: [PostModel]) {
        currentPostList = list
        tableView.reloadData()
    }
}

// MARK: LoadingViewHavingType
extension PostListViewController: LoadingViewType {}

// MARK: UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPostList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell else {
            fatalError("unable to dequeue cell with identifier: \(PostCell.reuseIdentifier)")
        }
        let post = currentPostList[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = post.title
        return cell
    }
}

// MARK: UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = currentPostList[indexPath.row]
        delegate?.postListViewController(self, didSelectPost: post)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
