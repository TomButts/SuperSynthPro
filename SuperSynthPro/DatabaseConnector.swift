/**
 * Database Connection singleton class
 */
import Foundation
import SQLite

class DatabaseConnector {
    // A shared static connection
    static var connection: Connection? = nil

    init() {
        // Find a read write db path to house the connection
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        
        // Only one instance will be created
        if (DatabaseConnector.connection == nil) {
            // Try to connect
            DatabaseConnector.connection = try! Connection("\(path)/db.SuperSynthPro")
        }
        
        // Print the db path so you can navigate to it and inpect using sqlite3 command in terminal
        // print(path)
    }
}
