// GENERATED from Spotly Web contracts/spotly-countries.v1.json. Do not edit by hand.
import Foundation

nonisolated enum SpotlyCountryContractMetadata {
    static let version = "1.0.0"
    static let manifestSHA256 = "ed5c19a48652334085bdf195a1817bff3ad2d76c135c22ea9eb5214d2e27edfc"
}

nonisolated struct SpotlyCountryPhoneRule: Codable, Hashable, Sendable { let nationalMinDigits: Int; let nationalMaxDigits: Int }
nonisolated struct SpotlyCountryBounds: Codable, Hashable, Sendable { let minLat: Double; let maxLat: Double; let minLng: Double; let maxLng: Double }
nonisolated struct SpotlyCountryMapCenter: Codable, Hashable, Sendable { let lat: Double; let lng: Double; let zoom: Double }
nonisolated struct SpotlyCountryCity: Codable, Hashable, Identifiable, Sendable { let id: String; let name: String; let lat: Double; let lng: Double }
nonisolated struct SpotlyCountryDefinition: Codable, Hashable, Identifiable, Sendable {
    var id: String { code.rawValue }
    let code: SpotlyCountryCode
    let name: String
    let demonym: String
    let dialCode: String
    let timeZone: String
    let locale: String
    let languageCodes: [String]
    let currencyPriority: [SpotlyCurrencyCode]
    let phone: SpotlyCountryPhoneRule
    let bounds: SpotlyCountryBounds
    let mapCenter: SpotlyCountryMapCenter
    let cities: [SpotlyCountryCity]
}

nonisolated enum SpotlyCountryCatalog {
    static let countries: [SpotlyCountryDefinition] = [
        SpotlyCountryDefinition(code: .ZW, name: "Zimbabwe", demonym: "Zimbabwean", dialCode: "+263", timeZone: "Africa/Harare", locale: "en_ZW", languageCodes: ["en","sn","nd"], currencyPriority: [.USD, .ZWG], phone: SpotlyCountryPhoneRule(nationalMinDigits: 9, nationalMaxDigits: 9), bounds: SpotlyCountryBounds(minLat: -22.6, maxLat: -15.55, minLng: 25.15, maxLng: 33.15), mapCenter: SpotlyCountryMapCenter(lat: -17.8252, lng: 31.0335, zoom: 6.2), cities: [SpotlyCountryCity(id: "harare", name: "Harare", lat: -17.8252, lng: 31.0335), SpotlyCountryCity(id: "bulawayo", name: "Bulawayo", lat: -20.1325, lng: 28.6265), SpotlyCountryCity(id: "mutare", name: "Mutare", lat: -18.9707, lng: 32.6709), SpotlyCountryCity(id: "gweru", name: "Gweru", lat: -19.455, lng: 29.817), SpotlyCountryCity(id: "victoria-falls", name: "Victoria Falls", lat: -17.9243, lng: 25.8572)]),
        SpotlyCountryDefinition(code: .MW, name: "Malawi", demonym: "Malawian", dialCode: "+265", timeZone: "Africa/Blantyre", locale: "en_MW", languageCodes: ["en","ny"], currencyPriority: [.MWK], phone: SpotlyCountryPhoneRule(nationalMinDigits: 9, nationalMaxDigits: 9), bounds: SpotlyCountryBounds(minLat: -17.18, maxLat: -9.3, minLng: 32.6, maxLng: 36.48), mapCenter: SpotlyCountryMapCenter(lat: -13.9626, lng: 33.7741, zoom: 6.2), cities: [SpotlyCountryCity(id: "lilongwe", name: "Lilongwe", lat: -13.9626, lng: 33.7741), SpotlyCountryCity(id: "blantyre", name: "Blantyre", lat: -15.7861, lng: 35.0058), SpotlyCountryCity(id: "mzuzu", name: "Mzuzu", lat: -11.4656, lng: 34.0207), SpotlyCountryCity(id: "zomba", name: "Zomba", lat: -15.3833, lng: 35.3333)])
    ]
    static func definition(for code: SpotlyCountryCode) -> SpotlyCountryDefinition { countries.first(where: { $0.code == code })! }
    static func country(latitude: Double, longitude: Double) -> SpotlyCountryCode? {
        countries.first(where: { latitude >= $0.bounds.minLat && latitude <= $0.bounds.maxLat && longitude >= $0.bounds.minLng && longitude <= $0.bounds.maxLng })?.code
    }
}
