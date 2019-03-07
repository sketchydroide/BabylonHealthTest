enum AsyncState<Content> {
    case loading
    case content(Content)
    case failed(TitledError)
}
