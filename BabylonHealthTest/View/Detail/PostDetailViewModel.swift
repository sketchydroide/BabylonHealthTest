import RxSwift

protocol PostDetailViewModelType {
    var title: String { get }
    var asyncStateObservable: Observable<AsyncState<PostDetailsModel>> { get }
    func loadPostDetails()
}

struct PostDetailViewModel: PostDetailViewModelType {
    private let commentsAsynStateSubject = BehaviorSubject<AsyncState<[CommentModel]>>(value: .loading)
    private let userAsynStateSubject = BehaviorSubject<AsyncState<UserModel>>(value: .loading)
    private let postModel: PostModel
    private let userService: UserServiceType
    private let commentsService: CommentsServiceType
    
    let title: String = Titles.postDetails.rawValue
    
    var asyncStateObservable: Observable<AsyncState<PostDetailsModel>> {
        return Observable.combineLatest(userAsynStateSubject.asObservable(), commentsAsynStateSubject.asObservable())
            .map { (userState, commentsState) -> AsyncState<PostDetailsModel> in
                switch (userState, commentsState) {
                case (.loading, _), (_, .loading):
                    return .loading
                case (.failed, _), (_, .failed):
                    return .failed(PostDetailsError.failedToGetDetails)
                case let (.content(user), .content(commentList)):
                    return .content(PostDetailsModel(post: self.postModel, authorName: user.name, numberOfComments: commentList.count))
                default:
                    return .loading
                }
            }
    }
    
    init(postModel: PostModel, userService: UserServiceType, commentsService: CommentsServiceType) {
        self.postModel = postModel
        self.userService = userService
        self.commentsService = commentsService
    }
    
    func loadPostDetails() {
        commentsAsynStateSubject.onNext(.loading)
        userAsynStateSubject.onNext(.loading)
        
        userService.fetchUser(with: postModel.userId) { (result: Result<UserModel>) in
            switch result {
            case let .success(user):
                self.userAsynStateSubject.onNext(.content(user))
            case let .failure(error):
                self.userAsynStateSubject.onNext(.failed(error))
            }
        }
        commentsService.fetchComments(for: postModel.id) { (result: Result<[CommentModel]>) in
            switch result {
            case let .success(commentList):
                self.commentsAsynStateSubject.onNext(.content(commentList))
            case let .failure(error):
                self.commentsAsynStateSubject.onNext(.failed(error))
            }
        }
    }
}
