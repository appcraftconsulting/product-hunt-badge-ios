import SwiftUI

internal struct UpvotesTransitionModifier: ViewModifier {
    internal let votesCount: Int
    
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
