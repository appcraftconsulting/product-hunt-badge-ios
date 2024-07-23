internal struct PostResponse: Decodable {
    struct Data: Decodable {
        let post: Post?
    }
    
    struct Post: Decodable {
        let votesCount: Int
    }
    
    let data: Data
}
