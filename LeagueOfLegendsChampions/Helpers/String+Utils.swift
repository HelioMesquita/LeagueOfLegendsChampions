import Foundation

extension String {

    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

}
