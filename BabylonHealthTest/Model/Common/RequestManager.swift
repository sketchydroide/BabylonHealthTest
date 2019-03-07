import Alamofire

protocol RequestManagerType {
    func makeNetworkCall<T: Decodable>(using resource: Resource, onCompletion completionHandler: @escaping (_ result: Result<T>) -> ())
}

final class RequestManager: RequestManagerType {
    func makeNetworkCall<T: Decodable>(using resource: Resource, onCompletion completionHandler: @escaping (_ result: Result<T>) -> ()) {
        do {
            try resource.makeRequest().validate()
                .responseData(completionHandler: { response in
                    guard response.result.isSuccess else {
                        if let error = response.error {
                            completionHandler(Result.failure(NetworkError.request(error)))
                        } else {
                            completionHandler(Result.failure(NetworkError.unknownError))
                        }
                        return
                    }
                    guard let data = response.data else {
                        completionHandler(Result.failure(NetworkError.noData))
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    do {
                        let content = try decoder.decode(T.self, from: data)
                        completionHandler(Result.success(content))
                    } catch {
                        completionHandler(Result.failure(NetworkError.decoding(error)))
                    }
                })
        } catch {
            completionHandler(Result.failure(NetworkError.resource(error)))
        }
    }
}

