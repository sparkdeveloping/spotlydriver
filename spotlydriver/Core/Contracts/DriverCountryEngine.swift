import Foundation

nonisolated enum DriverCountryEngine {
    static func definition(for code: SpotlyCountryCode) -> SpotlyCountryDefinition { SpotlyCountryCatalog.definition(for: code) }
    static func normalizePhone(_ value: String, country code: SpotlyCountryCode) throws -> String {
        let country = definition(for: code)
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "" }
        var digits = raw.filter(\.isNumber)
        let dial = country.dialCode.filter(\.isNumber)
        if digits.hasPrefix("00") { digits.removeFirst(2) }
        if digits.hasPrefix(dial) { digits.removeFirst(dial.count) }
        if digits.hasPrefix("0") { digits.removeFirst() }
        guard digits.count >= country.phone.nationalMinDigits, digits.count <= country.phone.nationalMaxDigits else {
            throw NSError(domain: "SpotlyDriverCountry", code: 1, userInfo: [NSLocalizedDescriptionKey: "Enter a valid \(country.name) phone number."])
        }
        return country.dialCode + digits
    }
}
