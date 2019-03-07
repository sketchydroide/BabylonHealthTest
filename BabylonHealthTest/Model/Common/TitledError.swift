protocol TitledError: Error {
    var title: String { get }
    var body: String { get }
}

extension TitledError {
    var title: String { return "Sorry!" }
}
