// swiftlint:disable all
import Amplify
import Foundation

public struct Category: Model {
  public let id: String
  public var name: String
  public var isDefault: Bool?
  public var entries: List<Entry>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      isDefault: Bool? = nil,
      entries: List<Entry>? = []) {
    self.init(id: id,
      name: name,
      isDefault: isDefault,
      entries: entries,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      isDefault: Bool? = nil,
      entries: List<Entry>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.isDefault = isDefault
      self.entries = entries
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}

extension Category: Identifiable {}