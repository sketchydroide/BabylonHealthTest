import XCTest
import RxSwift
@testable import BabylonHealthTest

class PostListViewModelTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    var postService: PostListServiceMock!
    var model: PostListViewModel!
    
    override func setUp() {
        postService = PostListServiceMock()
        model = PostListViewModel(service: postService)
    }
    
    override func tearDown() {
        postService = nil
        model = nil
    }
    
    func testTitle() {
        XCTAssertEqual(model.title, Titles.postList.rawValue)
    }
    
    func testStateStartsWithLoading() {
        let expectation = XCTestExpectation(description: "Should be loading")
        model.asynStateObservable
            .subscribe(onNext: { (state: AsyncState<[PostModel]>) in
                if case .loading = state {
                    expectation.fulfill()
                }
            }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 0.0)
    }
    
    func testStateHasContentIfServiceHasContent() {
        postService.mockPostList = []
        model.loadPosts()
        
        let expectation = XCTestExpectation(description: "Should have content")
        model.asynStateObservable
            .subscribe(onNext: { (state: AsyncState<[PostModel]>) in
                if case .content = state {
                    expectation.fulfill()
                }
            }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 0.0)
    }
    
    func testStateFailsIfServiceHasError() {
        postService.mockError = MockError.mockError
        model.loadPosts()
        
        let expectation = XCTestExpectation(description: "Should have content")
        model.asynStateObservable
            .subscribe(onNext: { (state: AsyncState<[PostModel]>) in
                if case .failed = state {
                    expectation.fulfill()
                }
            }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 0.0)
    }
}
