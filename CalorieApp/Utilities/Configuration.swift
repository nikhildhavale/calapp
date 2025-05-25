import Foundation

enum ConfigurationError: Error {
    case missingKey(String)
    case invalidPlistFile
}

class Configuration {
    static let shared = Configuration()
    private var configDict: [String: Any]?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            configDict = dict
        }
    }
    
    func getValue(for key: String) throws -> String {
        guard let dict = configDict else {
            throw ConfigurationError.invalidPlistFile
        }
        
        guard let value = dict[key] as? String else {
            throw ConfigurationError.missingKey(key)
        }
        
        return value
    }
    
    var openAIAPIKey: String {
        get throws {
            try getValue(for: "OpenAIAPIKey")
        }
    }
} 