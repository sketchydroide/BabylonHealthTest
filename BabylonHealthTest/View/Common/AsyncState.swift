enum AsyncState<T> {
    case loading
    case content(T)
    case failed(TitledError)
}
