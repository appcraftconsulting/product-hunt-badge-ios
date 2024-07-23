import SwiftUI

public struct ProductHuntBadge: View {
    @StateObject private var viewModel: ProductHuntBadgeViewModel
    @Environment(\.productHuntCredentials) private var credentials
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("com.appcraftconsulting.producthuntbadge.votescount")
    private var votesCount: Int = 0
    
    private var upvotes: Int {
        viewModel.votesCount ?? votesCount
    }
    
    private let url: URL!
    
    public init(slug: String) {
        url = URL(string: "https://www.producthunt.com/posts/\(slug)")
        _viewModel = .init(wrappedValue: .init(postIdentifier: .slug(slug)))
    }
    
    public init(id: Int) {
        url = URL(string: "https://www.producthunt.com/posts/\(id)")
        _viewModel = .init(wrappedValue: .init(postIdentifier: .id(id)))
    }
    
    public var body: some View {
        Link(destination: url) {
            HStack(alignment: .center, spacing: 10) {
                Image(.logo)
                    .foregroundStyle(Color(.logoForeground))
                
                VStack(alignment: .leading, spacing: -2) {
                    Text(verbatim: "Featured on")
                        .font(.custom("Helvetica-Bold", size: 9))
                        .textCase(.uppercase)
                        .offset(x: 1)
                    
                    Text(verbatim: "Product Hunt")
                        .font(.custom("Helvetica-Bold", size: 21))
                }
                
                Spacer(minLength: 0)
                
                VStack(alignment: .center, spacing: 4) {
                    Image(.upvote)
                    
                    Text(upvotes, format: .number)
                        .font(.custom("Helvetica-Bold", size: 13))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .modifier(UpvotesTransitionModifier(upvotes: upvotes))
                        .animation(.default, value: upvotes)
                }
                .frame(width: 32)
            }
            .padding(.horizontal, 10)
            .frame(width: 250, height: 54)
            .foregroundStyle(Color(.badgeForeground))
            .background(Color(.badgeBackground), in: .rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.badgeBorder), lineWidth: 1)
            }
        }
        .onChange(of: viewModel.votesCount) { votesCount in
            if let votesCount {
                self.votesCount = votesCount
            }
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .active {
                viewModel.refresh(credentials: credentials!)
            }
        }
        .onAppear {
            viewModel.refresh(credentials: credentials!)
        }
    }
}
