import Foundation

enum AppConfigurationError: Error {
    case missingKey(String)
    case invalidPlistFile
}

class AppConfiguration {
    static let shared = AppConfiguration()
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
            throw AppConfigurationError.invalidPlistFile
        }
        
        guard let value = dict[key] as? String else {
            throw AppConfigurationError.missingKey(key)
        }
        
        return value
    }
    
    var openAIAPIKey: String {
        get throws {
            try getValue(for: "OpenAIAPIKey")
        }
    }
} 