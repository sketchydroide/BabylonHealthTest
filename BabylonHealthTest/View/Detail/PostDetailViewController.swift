import RxSwift
import UIKit

protocol PostDetailViewControllerDelegate: class {
    func postDetailViewController(_ vc: PostDetailViewController, didHaveAnError error: TitledError)
}

final class PostDetailViewController: UIViewController {
    @IBOutlet var authorsNameLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var numberCommentsLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    
    private let viewModel: PostDetailViewModelType
    private let disposeBag = DisposeBag()
    
    weak var delegate: PostDetailViewControllerDelegate?
    
    init(viewModel: PostDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadPostDetails()
        bind(with: viewModel)
    }
    
    private func bind(with viewModel: PostDetailViewModelType) {
        viewModel.asyncStateObservable
            .subscribe(onNext: { state in
                DispatchQueue.main.async {
                    switch state {
                    case .loading:
                        self.showLoading()
                    case let .failed(error):
                        self.hideLoading()
                        self.delegate?.postDetailViewController(self, didHaveAnError: error)
                    case let .content(postDetails):
                        self.hideLoading()
                        self.updatePostInfo(with: postDetails)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func updatePostInfo(with details: PostDetailsModel) {
        authorsNameLabel.text = "\(details.authorName) \(StringConstants.posted.rawValue):"
        bodyLabel.text = details.body
        numberCommentsLabel.text = "\(details.numberOfComments) \(details.numberOfComments == 1 ? "\(StringConstants.comment.rawValue)" : "\(StringConstants.comments.rawValue)")"
    }
}

// MARK: LoadingViewHavingType
extension PostDetailViewController: LoadingViewType {}
