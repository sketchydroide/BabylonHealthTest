import UIKit

protocol LoadingViewType {
    var loadingView: UIView! { get set }
}

extension LoadingViewType {
    func showLoading() {
        loadingView.isHidden = false
    }

    func hideLoading() {
        loadingView.isHidden = true
    }
}
