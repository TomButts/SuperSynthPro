import Foundation
import SQLite

final class DatabaseConnector {
    static var connection: Connection = try! Connection("db.sqlite")

    private init() {
    
    }
}
