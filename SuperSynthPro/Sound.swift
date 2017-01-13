
import Foundation
import SQLite
import AudioKit

class Sound {
    var db: Connection = DatabaseConnector.connection!
    
    
    func serialiseCurrentSound() {
        var audioHandler = AudioHandler.sharedInstance
    }
}
