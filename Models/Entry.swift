// swiftlint:disable all
import Amplify
import Foundation

public struct Entry: Model {
  public let id: String
  public var date: Temporal.Date
  public var totalMinutes: Int
  public var performer: String
  public var activityType: String
  public var notes: String?
  public var images: [String?]?
  public var startTime: Temporal.Time?
  public var endTime: Temporal.Time?
  internal var _property: LazyReference<Property>
  public var property: Property?   {
      get async throws { 
        try await _property.get()
      } 
    }
  internal var _category: LazyReference<Category>
  public var category: Category?   {
      get async throws { 
        try await _category.get()
      } 
    }
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      date: Temporal.Date,
      totalMinutes: Int,
      performer: String,
      activityType: String,
      notes: String? = nil,
      images: [String?]? = nil,
      startTime: Temporal.Time? = nil,
      endTime: Temporal.Time? = nil,
      property: Property? = nil,
      category: Category? = nil) {
    self.init(id: id,
      date: date,
      totalMinutes: totalMinutes,
      performer: performer,
      activityType: activityType,
      notes: notes,
      images: images,
      startTime: startTime,
      endTime: endTime,
      property: property,
      category: category,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      date: Temporal.Date,
      totalMinutes: Int,
      performer: String,
      activityType: String,
      notes: String? = nil,
      images: [String?]? = nil,
      startTime: Temporal.Time? = nil,
      endTime: Temporal.Time? = nil,
      property: Property? = nil,
      category: Category? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.date = date
      self.totalMinutes = totalMinutes
      self.performer = performer
      self.activityType = activityType
      self.notes = notes
      self.images = images
      self.startTime = startTime
      self.endTime = endTime
      self._property = LazyReference(property)
      self._category = LazyReference(category)
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
  public mutating func setProperty(_ property: Property? = nil) {
    self._property = LazyReference(property)
  }
  public mutating func setCategory(_ category: Category? = nil) {
    self._category = LazyReference(category)
  }
  public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(String.self, forKey: .id)
      date = try values.decode(Temporal.Date.self, forKey: .date)
      totalMinutes = try values.decode(Int.self, forKey: .totalMinutes)
      performer = try values.decode(String.self, forKey: .performer)
      activityType = try values.decode(String.self, forKey: .activityType)
      notes = try? values.decode(String?.self, forKey: .notes)
      images = try? values.decode([String].self, forKey: .images)
      startTime = try? values.decode(Temporal.Time?.self, forKey: .startTime)
      endTime = try? values.decode(Temporal.Time?.self, forKey: .endTime)
      _property = try values.decodeIfPresent(LazyReference<Property>.self, forKey: .property) ?? LazyReference(identifiers: nil)
      _category = try values.decodeIfPresent(LazyReference<Category>.self, forKey: .category) ?? LazyReference(identifiers: nil)
      createdAt = try? values.decode(Temporal.DateTime?.self, forKey: .createdAt)
      updatedAt = try? values.decode(Temporal.DateTime?.self, forKey: .updatedAt)
  }
  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(date, forKey: .date)
      try container.encode(totalMinutes, forKey: .totalMinutes)
      try container.encode(performer, forKey: .performer)
      try container.encode(activityType, forKey: .activityType)
      try container.encode(notes, forKey: .notes)
      try container.encode(images, forKey: .images)
      try container.encode(startTime, forKey: .startTime)
      try container.encode(endTime, forKey: .endTime)
      try container.encode(_property, forKey: .property)
      try container.encode(_category, forKey: .category)
      try container.encode(createdAt, forKey: .createdAt)
      try container.encode(updatedAt, forKey: .updatedAt)
  }
}

extension Entry: Identifiable {}