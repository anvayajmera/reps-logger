// swiftlint:disable all
import Amplify
import Foundation

public struct Property: Model {
  public let id: String
  public var name: String
  public var nickname: String?
  public var type: String
  public var address1: String
  public var address2: String?
  public var city: String
  public var state: String
  public var zip: String
  public var acquiredDate: Temporal.Date?
  public var isActive: Bool?
  public var notes: String?
  public var entries: List<Entry>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      name: String,
      nickname: String? = nil,
      type: String,
      address1: String,
      address2: String? = nil,
      city: String,
      state: String,
      zip: String,
      acquiredDate: Temporal.Date? = nil,
      isActive: Bool? = nil,
      notes: String? = nil,
      entries: List<Entry>? = []) {
    self.init(id: id,
      name: name,
      nickname: nickname,
      type: type,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      zip: zip,
      acquiredDate: acquiredDate,
      isActive: isActive,
      notes: notes,
      entries: entries,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      name: String,
      nickname: String? = nil,
      type: String,
      address1: String,
      address2: String? = nil,
      city: String,
      state: String,
      zip: String,
      acquiredDate: Temporal.Date? = nil,
      isActive: Bool? = nil,
      notes: String? = nil,
      entries: List<Entry>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.name = name
      self.nickname = nickname
      self.type = type
      self.address1 = address1
      self.address2 = address2
      self.city = city
      self.state = state
      self.zip = zip
      self.acquiredDate = acquiredDate
      self.isActive = isActive
      self.notes = notes
      self.entries = entries
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}

extension Property: Identifiable {}