import Foundation
import SQLite

class DatabaseConnector {
    static var connection: Connection? = nil

    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        
        if (DatabaseConnector.connection == nil) {
            DatabaseConnector.connection = try! Connection("\(path)/db.SuperSynthPro")
        }
        
        print(path)
    }
}
