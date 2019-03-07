struct UserModel: Codable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: AddressModel
    let company: CompanyModel
}
