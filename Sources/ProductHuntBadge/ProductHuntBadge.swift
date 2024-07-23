import SwiftUI

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
        .foregroundStyle(Color(.badgeForeground))
        .background(Color(.badgeBackground), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.badgeBorder), lineWidth: 1)
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
