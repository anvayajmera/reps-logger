import { type ClientSchema, a } from "@aws-amplify/backend";

export const schema = a.schema({
  Property: a
    .model({
      name: a.string().required(),
      nickname: a.string(),
      type: a.string().required(),             // LTR or STR
      address1: a.string().required(),
      address2: a.string(),
      city: a.string().required(),
      state: a.string().required(),
      zip: a.string().required(),
      acquiredDate: a.date(),
      isActive: a.boolean().default(true),
      notes: a.string(),

      entries: a.hasMany("Entry", "propertyID"),
    })
    .authorization((allow) => [allow.owner()]),

  Category: a
    .model({
      name: a.string().required(),
      isDefault: a.boolean().default(false),

      entries: a.hasMany("Entry", "categoryID"),
    })
    .authorization((allow) => [allow.owner()]),

  Entry: a
    .model({
      propertyID: a.id().required(),
      categoryID: a.id(),
      date: a.date().required(),
      totalMinutes: a.integer().required(),
      performer: a.string().required(),
      activityType: a.string().required(),
      notes: a.string(),
      images: a.string().array(),

      startTime: a.time(),
      endTime: a.time(),

      property: a.belongsTo("Property", "propertyID"),
      category: a.belongsTo("Category", "categoryID"),
    })
    .authorization((allow) => [allow.owner()]),
});

export type Schema = ClientSchema<typeof schema>;

