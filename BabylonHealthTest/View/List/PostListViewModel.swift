import RxSwift

protocol PostListViewModelType {
    var title: String { get }
    var asynStateObservable: Observable<AsyncState<[PostModel]>> { get }
    func loadPosts()
}

struct PostListViewModel: PostListViewModelType {
    private let asynStateSubject = BehaviorSubject<AsyncState<[PostModel]>>(value: .loading)
    
    let title: String = Titles.postList.rawValue
    let service: PostListServiceType
    
    var asynStateObservable: Observable<AsyncState<[PostModel]>> {
        return asynStateSubject.asObservable()
    }
    
    init(service: PostListServiceType) {
        self.service = service
    }
    
    func loadPosts() {
        asynStateSubject.onNext(.loading)
        service.refreshPosts { (result: Result<[PostModel]>) in
            switch result {
            case let .success(postList):
                self.asynStateSubject.onNext(.content(postList))
            case let .failure(error):
                self.asynStateSubject.onNext(.failed(error))
            }
        }
    }
}
