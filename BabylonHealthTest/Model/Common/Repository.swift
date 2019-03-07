import Foundation

enum RepositoryError: TitledError {
    case failedRead

    var body: String {
        switch self {
        case .failedRead:
            return "Did not manage to read data!"
        }
    }
}

protocol RepositoryType {}

extension RepositoryType {
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsPath = paths.first else { fatalError() }
        return documentsPath
    }

    var fullPath: URL {
        return documentsDirectory.appendingPathComponent(String(describing: self))
    }
}

class Repository<Value: Codable>: RepositoryType {
    func loadValue() -> Value? {
        do {
            guard let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: fullPath)) as? Data else {
                fatalError("Failed to read from repository \(String(describing: self))")
            }
            return try PropertyListDecoder().decode(Value.self, from: data)
        } catch {
            // If failed to read from repository or failed to parse I want to crash and let the developers know of a major issue that needs to be fixed
            fatalError("Failed to read from repository \(String(describing: self))")
        }
    }

    func saveValue(value: Value) {
        do {
            let data = try PropertyListEncoder().encode(value)
            try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
                .write(to: fullPath)
        } catch {
            // If failed to write to repository or failed to parse I want to crash and let the developers know of a major issue that needs to be fixed
            fatalError("Failed to write to repository !")
        }
    }
}
