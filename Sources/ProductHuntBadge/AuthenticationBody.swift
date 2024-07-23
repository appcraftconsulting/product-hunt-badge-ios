internal struct AuthenticationBody: Encodable {
    enum GrantType: String, Encodable {
        case clientCredentials = "client_credentials"
    }
    
    let clientId: String
    let clientSecret: String
    var grantType: GrantType = .clientCredentials
}
