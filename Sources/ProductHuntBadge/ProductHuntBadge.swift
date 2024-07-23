// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct ProductHuntCredentials {
    internal let clientId: String
    internal let clientSecret: String
    
    public init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
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
    public func productHuntCredentials(_ credentials: ProductHuntCredentials) -> some View {
        environment(\.productHuntCredentials, credentials)
    }
}

internal class ProductHuntBadgeViewModel: ObservableObject {
    @Published internal var votesCount: Int = 0
    
    internal enum PostIdentifier {
        case slug(String)
        case id(Int)
        
        var parameters: String {
            switch self {
            case let .slug(slug):
                return "slug: \\\"\(slug)\\\""
            case let .id(id):
                return "id: \(id)"
            }
        }
    }
    
    private struct PostResponse: Decodable {
        struct Data: Decodable {
            let post: Post?
        }
        
        struct Post: Decodable {
            let votesCount: Int
        }
        
        let data: Data
    }
    
    private struct AuthenticationBody: Encodable {
        enum GrantType: String, Encodable {
            case clientCredentials = "client_credentials"
        }
        
        let clientId: String
        let clientSecret: String
        let grantType: GrantType
        
        init(credentials: ProductHuntCredentials) {
            self.clientId = credentials.clientId
            self.clientSecret = credentials.clientSecret
            self.grantType = .clientCredentials
        }
    }
    
    private struct AuthenticationResponse: Decodable {
        let accessToken: String
    }
    
    private let session: URLSession = .shared
    private var task: Task<Void, Error>?
    private let query: String
        
    internal init(postIdentifier: PostIdentifier) {
        query = "{\"query\":\"{\n  post(\(postIdentifier.parameters)) {\n votesCount\n  }\n}\n\",\"variables\":null}"
    }
    
    
    internal func fetch(credentials: ProductHuntCredentials) {
        task = .init { @MainActor in
            do {
                let accessToken = try await authenticate(with: credentials)
                
                let url = URL(string: "https://api.producthunt.com/v2/api/graphql")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = query.data(using: .utf8)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let (data, _) = try await session.data(for: request)
                print(String(data: data, encoding: .utf8))
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(PostResponse.self, from: data)
                votesCount = response.data.post?.votesCount ?? 0
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private functions
    
    private func authenticate(with credentials: ProductHuntCredentials) async throws -> String {
        let url = URL(string: "https://api.producthunt.com/v2/oauth/token")!
        let body = AuthenticationBody(credentials: credentials)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, _) = try await session.data(for: request)
        print(String(data: data, encoding: .utf8))
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(AuthenticationResponse.self, from: data)
        return response.accessToken
    }
}

public struct ProductHuntBadge: View {
    @StateObject private var viewModel: ProductHuntBadgeViewModel
    @Environment(\.productHuntCredentials) private var credentials
    @Environment(\.scenePhase) private var scenePhase
    
    public init(slug: String) {
        _viewModel = .init(wrappedValue: .init(postIdentifier: .slug(slug)))
    }
    
    public init(id: Int) {
        _viewModel = .init(wrappedValue: .init(postIdentifier: .id(id)))
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(.logo)
                .foregroundStyle(Color("LogoForeground", bundle: .module))
            
            VStack(alignment: .leading, spacing: -2) {
                Text(verbatim: "FEATURED ON")
                    .font(.custom("Helvetica-Bold", size: 9))
                    .offset(x: 1)
                
                Text(verbatim: "Product Hunt")
                    .font(.custom("Helvetica-Bold", size: 21))
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .center, spacing: 4) {
                Image(.upvote)
                
                Text(viewModel.votesCount, format: .number)
                    .font(.custom("Helvetica-Bold", size: 13))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .modifier(UpvotesTransitionModifier(votesCount: viewModel.votesCount))
                    .animation(.default, value: viewModel.votesCount)
            }
            .frame(width: 32)
        }
        .padding(.horizontal, 10)
        .frame(width: 250, height: 54)
        .foregroundStyle(Color("BadgeForeground", bundle: .module))
        .background(Color("BadgeBackground", bundle: .module), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("BadgeBorder", bundle: .module), lineWidth: 1)
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .active {
                viewModel.fetch(credentials: credentials!)
            }
        }
        .onAppear {
            viewModel.fetch(credentials: credentials!)
        }
    }
}

struct UpvotesTransitionModifier: ViewModifier {
    let votesCount: Int
    
    private var value: Double {
        Double(votesCount)
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .contentTransition(.numericText(value: value))
        } else if #available(iOS 16.0, *) {
            content
                .contentTransition(.numericText())
        } else {
            content
        }
    }
}
