# REPSLogger

A native iOS application for real estate professionals to track and log time spent on property-related activities (REPS - Real Estate Professional Services). Built with SwiftUI and AWS Amplify, featuring secure cloud storage and real-time data synchronization.

## Screenshots

<table>
  <tr>
    <td width="33%">
      <img src="screenshots/properties.png" alt="Properties View" />
    </td>
    <td width="33%">
      <img src="screenshots/add_entry.png" alt="Add Entry Form" />
    </td>
    <td width="33%">
      <img src="screenshots/entries.png" alt="Entries List" />
    </td>
  </tr>
</table>

## Overview

REPSLogger helps real estate professionals track time spent on property management activities, organize entries by property and category, and maintain supporting documentation for tax and reporting purposes.

## Technology Stack

**Frontend**  
<img src="https://img.shields.io/badge/SwiftUI-00599C?logo=swift&logoColor=white" alt="SwiftUI" /> <img src="https://img.shields.io/badge/Swift-FA7343?logo=swift&logoColor=white" alt="Swift" />

**Backend & Infrastructure**  
<img src="https://img.shields.io/badge/AWS%20Amplify-FF9900?logo=aws-amplify&logoColor=white" alt="AWS Amplify" /> <img src="https://img.shields.io/badge/AWS%20AppSync-FF9900?logo=amazon-aws&logoColor=white" alt="AWS AppSync" /> <img src="https://img.shields.io/badge/Amazon%20DynamoDB-4053D6?logo=amazon-dynamodb&logoColor=white" alt="DynamoDB" /> <img src="https://img.shields.io/badge/AWS%20Cognito-FF9900?logo=amazon-aws&logoColor=white" alt="AWS Cognito" /> <img src="https://img.shields.io/badge/Amazon%20S3-569A31?logo=amazon-s3&logoColor=white" alt="Amazon S3" /> <img src="https://img.shields.io/badge/AWS%20IAM-FF9900?logo=amazon-aws&logoColor=white" alt="AWS IAM" />

**Development Tools**  
<img src="https://img.shields.io/badge/TypeScript-007ACC?logo=typescript&logoColor=white" alt="TypeScript" /> <img src="https://img.shields.io/badge/AWS%20CDK-FF9900?logo=amazon-aws&logoColor=white" alt="AWS CDK" /> <img src="https://img.shields.io/badge/GraphQL-E10098?logo=graphql&logoColor=white" alt="GraphQL" /> <img src="https://img.shields.io/badge/Xcode-007ACC?logo=xcode&logoColor=white" alt="Xcode" />

## Key Features

**User Authentication**
- Email-based authentication with AWS Cognito
- User-specific data isolation with owner-based authorization

**Property Management**
- Add, edit, and delete properties (LTR/STR)
- Store property details including address, acquisition date, and notes

**Activity Logging**
- Create entries with date, duration, activity description, property association, and performer
- Optional category classification
- Edit and delete entries with chronological viewing



## Architecture

**Data Model**
Three main entities: Property (real estate properties), Category (entry organization), and Entry (activity logs with relationships).

**Security**
- Owner-based authorization for data isolation
- IAM policies for S3 access control
- Cognito token authentication
- Data encryption in transit and at rest

**Backend**
- GraphQL schema defined in TypeScript
- Automatic API generation
- Identity-based storage paths (`entries/{identity_id}/*`)

## Getting Started

**Prerequisites**
- macOS with Xcode 14.0+, iOS 16.0+, Node.js 18.x+, AWS Account

**Installation**
1. Clone repository and install dependencies: `npm install`
2. Configure Amplify backend: `npx ampx sandbox`
3. Generate Swift models: `npx ampx codegen`
4. Open in Xcode: `open REPSLogger.xcodeproj`
5. Build and run

## Project Structure

```
REPSLogger/
├── amplify/          # Backend configuration (auth, data, storage)
├── REPSLogger/       # iOS app (Views, ViewModels, Utilities, Models)
└── Models/           # Swift model definitions
```

*Built with SwiftUI and AWS Amplify*
