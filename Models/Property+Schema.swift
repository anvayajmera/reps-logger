// swiftlint:disable all
import Amplify
import Foundation

extension Property {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case nickname
    case type
    case address1
    case address2
    case city
    case state
    case zip
    case acquiredDate
    case isActive
    case notes
    case entries
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let property = Property.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Properties"
    model.syncPluralName = "Properties"
    
    model.attributes(
      .primaryKey(fields: [property.id])
    )
    
    model.fields(
      .field(property.id, is: .required, ofType: .string),
      .field(property.name, is: .required, ofType: .string),
      .field(property.nickname, is: .optional, ofType: .string),
      .field(property.type, is: .required, ofType: .string),
      .field(property.address1, is: .required, ofType: .string),
      .field(property.address2, is: .optional, ofType: .string),
      .field(property.city, is: .required, ofType: .string),
      .field(property.state, is: .required, ofType: .string),
      .field(property.zip, is: .required, ofType: .string),
      .field(property.acquiredDate, is: .optional, ofType: .date),
      .field(property.isActive, is: .optional, ofType: .bool),
      .field(property.notes, is: .optional, ofType: .string),
      .hasMany(property.entries, is: .optional, ofType: Entry.self, associatedFields: [Entry.keys.property]),
      .field(property.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(property.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    nonisolated public class Path: ModelPath<Property> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension Property: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
extension ModelPath where ModelType == Property {
  public var id: FieldPath<String>   {
      string("id") 
    }
  public var name: FieldPath<String>   {
      string("name") 
    }
  public var nickname: FieldPath<String>   {
      string("nickname") 
    }
  public var type: FieldPath<String>   {
      string("type") 
    }
  public var address1: FieldPath<String>   {
      string("address1") 
    }
  public var address2: FieldPath<String>   {
      string("address2") 
    }
  public var city: FieldPath<String>   {
      string("city") 
    }
  public var state: FieldPath<String>   {
      string("state") 
    }
  public var zip: FieldPath<String>   {
      string("zip") 
    }
  public var acquiredDate: FieldPath<Temporal.Date>   {
      date("acquiredDate") 
    }
  public var isActive: FieldPath<Bool>   {
      bool("isActive") 
    }
  public var notes: FieldPath<String>   {
      string("notes") 
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