// swiftlint:disable all
import Amplify
import Foundation

extension Category {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case isDefault
    case entries
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let category = Category.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Categories"
    model.syncPluralName = "Categories"
    
    model.attributes(
      .primaryKey(fields: [category.id])
    )
    
    model.fields(
      .field(category.id, is: .required, ofType: .string),
      .field(category.name, is: .required, ofType: .string),
      .field(category.isDefault, is: .optional, ofType: .bool),
      .hasMany(category.entries, is: .optional, ofType: Entry.self, associatedFields: [Entry.keys.category]),
      .field(category.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(category.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    nonisolated public class Path: ModelPath<Category> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension Category: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
extension ModelPath where ModelType == Category {
  public var id: FieldPath<String>   {
      string("id") 
    }
  public var name: FieldPath<String>   {
      string("name") 
    }
  public var isDefault: FieldPath<Bool>   {
      bool("isDefault") 
    }
  public var entries: ModelPath<Entry>   {
      Entry.Path(name: "entries", isCollection: true, parent: self) 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}