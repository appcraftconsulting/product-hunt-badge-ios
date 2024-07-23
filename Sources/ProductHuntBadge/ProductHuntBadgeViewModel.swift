import Foundation
import OSLog

internal final class ProductHuntBadgeViewModel: ObservableObject {
    @Published internal var votesCount: Int = 0
    
    private let session: URLSession = .shared
    private var task: Task<Void, Error>?
    private let query: String
        
    internal init(postIdentifier: PostIdentifier) {
        query = """
        {
            "query":
                "{
                    post(\(postIdentifier.parameters)) {
                        votesCount
                    }
                }",
            "variables":
                null
        }
        """
    }
    
    internal func refresh(credentials: ProductHuntCredentials) {
        task = .init { @MainActor in
            do {
                let accessToken = switch credentials {
                case let .application(clientId, clientSecret):
                    try await authenticate(clientId: clientId, clientSecret: clientSecret)
                case let .developerToken(accessToken):
                    accessToken
                }
                
                let url = URL(string: "https://api.producthunt.com/v2/api/graphql")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = query.data(using: .utf8)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let (data, _) = try await session.data(for: request)
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(PostResponse.self, from: data)
                if let post = response.data.post {
                    logger.info("Received votes count: \(post.votesCount)")
                    votesCount = post.votesCount
                } else {
                    logger.error("No post found for given identifier")
                }
            } catch {
                logger.error("Failed to refresh votes count: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private functions
    
    private func authenticate(clientId: String, clientSecret: String) async throws -> String {
        let url = URL(string: "https://api.producthunt.com/v2/oauth/token")!
        let body = AuthenticationBody(clientId: clientId, clientSecret: clientSecret)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(AuthenticationResponse.self, from: data)
        logger.info("Access token successfully generated for application")
        logger.debug("Access token: \(response.accessToken)")
        return response.accessToken
    }
}

fileprivate let logger = Logger(
    subsystem: "com.appcraftconsulting.producthuntbadge",
    category: "ProductHuntBadgeViewModel"
)
