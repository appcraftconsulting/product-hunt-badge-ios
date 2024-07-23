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
