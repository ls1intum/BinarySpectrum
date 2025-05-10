import Foundation

extension String {
    func paddingLeft(with character: Character, toLength: Int) -> String {
        return String(repeating: String(character), count: max(0, toLength - count)) + self
    }
}
