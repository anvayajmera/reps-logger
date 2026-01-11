// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "8b09aaa5e667533ca39035968e89d7d6"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Property.self)
    ModelRegistry.register(modelType: Category.self)
    ModelRegistry.register(modelType: Entry.self)
  }
}