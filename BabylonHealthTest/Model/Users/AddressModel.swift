struct AddressModel: Codable, Hashable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: GeoLocationModel
}

struct GeoLocationModel: Codable, Hashable {
    let lat: String
    let lng: String
}
