import Foundation

enum PostDetailsError: TitledError {
    case failedToGetDetails
    var body: String {
        switch self {
        case .failedToGetDetails:
            return "Encountered an error while trying to get the post details."
        }
    }
}

struct PostDetailsModel {
    let title: String
    let body: String
    let numberOfComments: Int
    let authorName: String

    init(post: PostModel, authorName: String, numberOfComments: Int) {
        self.title = post.title
        self.body = post.body
        self.authorName = authorName
        self.numberOfComments = numberOfComments
    }
}
