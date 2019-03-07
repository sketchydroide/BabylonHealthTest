enum Result<Content> {
    case success(Content)
    case failure(TitledError)
}
