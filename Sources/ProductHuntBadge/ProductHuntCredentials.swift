import SwiftUI

public enum ProductHuntCredentials {
    case application(clientId: String, clientSecret: String)
    case developerToken(_ accessToken: String)
}

private struct ProductHuntCredentialsKey: EnvironmentKey {
    static let defaultValue: ProductHuntCredentials? = nil
}

internal extension EnvironmentValues {
    var productHuntCredentials: ProductHuntCredentials? {
        get { self[ProductHuntCredentialsKey.self] }
        set { self[ProductHuntCredentialsKey.self] = newValue }
    }
}

public extension View {
    func productHuntCredentials(_ credentials: ProductHuntCredentials) -> some View {
        environment(\.productHuntCredentials, credentials)
    }
}
