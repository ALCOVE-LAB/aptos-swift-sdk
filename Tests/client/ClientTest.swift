
import XCTest
import Types
import Clients
import OpenAPIURLSession 

class ClientTest: XCTestCase {
    struct Converter: Convertible {}
    struct HttpBinClient: ClientProtocol {
        var serverURL: URL = URL.init(string: "https://httpbin.org")!
        var transport: ClientTransport = URLSessionTransport()
        var converter: Convertible = Converter()
        var middlewares: [ClientMiddleware] = []
    }

    enum HttpBinRequest: RequestOptions {
        case get

        var path: String {
            switch self {
            case .get:
                return "/get"
            }
        }
    }

    enum HttpBinPost: PostRequestOptions {
        case post

        var path: String {
            switch self {
            case .post:
                return "/post"
            }
        }

        var body: [String: Any]? {
            switch self {
            case .post:
                return ["key": "value"]
            }
        }
    }

    func testGet() async throws {
        let client = HttpBinClient()
        let (response, _) = try await client.get(HttpBinRequest.get)
        XCTAssertEqual(response.status.code, 200)
    }

    func testPost() async throws {
        let client = HttpBinClient()
        let (response, _) = try await client.post(HttpBinPost.post)
        XCTAssertEqual(response.status.code, 200)
    }
}