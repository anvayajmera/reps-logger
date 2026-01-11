// swiftlint:disable all
import Amplify
import Foundation

extension Entry {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case date
    case totalMinutes
    case performer
    case activityType
    case notes
    case images
    case startTime
    case endTime
    case property
    case category
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let entry = Entry.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Entries"
    model.syncPluralName = "Entries"
    
    model.attributes(
      .primaryKey(fields: [entry.id])
    )
    
    model.fields(
      .field(entry.id, is: .required, ofType: .string),
      .field(entry.date, is: .required, ofType: .date),
      .field(entry.totalMinutes, is: .required, ofType: .int),
      .field(entry.performer, is: .required, ofType: .string),
      .field(entry.activityType, is: .required, ofType: .string),
      .field(entry.notes, is: .optional, ofType: .string),
      .field(entry.images, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(entry.startTime, is: .optional, ofType: .time),
      .field(entry.endTime, is: .optional, ofType: .time),
      .belongsTo(entry.property, is: .optional, ofType: Property.self, targetNames: ["propertyID"]),
      .belongsTo(entry.category, is: .optional, ofType: Category.self, targetNames: ["categoryID"]),
      .field(entry.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(entry.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    nonisolated public class Path: ModelPath<Entry> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension Entry: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
extension ModelPath where ModelType == Entry {
  public var id: FieldPath<String>   {
      string("id") 
    }
  public var date: FieldPath<Temporal.Date>   {
      date("date") 
    }
  public var totalMinutes: FieldPath<Int>   {
      int("totalMinutes") 
    }
  public var performer: FieldPath<String>   {
      string("performer") 
    }
  public var activityType: FieldPath<String>   {
      string("activityType") 
    }
  public var notes: FieldPath<String>   {
      string("notes") 
    }
  public var images: FieldPath<String>   {
      string("images") 
    }
  public var startTime: FieldPath<Temporal.Time>   {
      time("startTime") 
    }
  public var endTime: FieldPath<Temporal.Time>   {
      time("endTime") 
    }
  public var property: ModelPath<Property>   {
      Property.Path(name: "property", parent: self) 
    }
  public var category: ModelPath<Category>   {
      Category.Path(name: "category", parent: self) 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}