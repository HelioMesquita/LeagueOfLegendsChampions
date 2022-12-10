import Foundation

extension Bundle {

    var scheme: String {
        return self.object(forInfoDictionaryKey: "SCHEME") as! String
    }

    var host: String {
        return self.object(forInfoDictionaryKey: "HOST") as! String
    }

    var displayName: String {
        return self.object(forInfoDictionaryKey: "CURRENT_NAME") as! String
    }

}
