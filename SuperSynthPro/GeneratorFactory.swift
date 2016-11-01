import Foundation
import AudioKit
import SQLite

class GeneratorFactory {
    static func createGenerator(generator: GeneratorStructure) -> GeneratorProtocol {
        switch (generator.type) {
            case "AKOscillator":
                return OscillatorCollection(generator: generator)
            default:
                return OscillatorCollection(generator: generator)
        }
    }
}
