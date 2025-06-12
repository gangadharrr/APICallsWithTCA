# Terminology Glossary

This document defines standard terminology used throughout the APICallsWithTCA project to ensure consistency between high-level documentation and code comments.

## The Composable Architecture (TCA) Terminology

| Term | Definition |
|------|------------|
| State | The data that represents the current condition of a feature. It should be a struct conforming to `Equatable`. |
| Action | An event that can occur in a feature, typically modeled as an enum. Actions trigger state changes and effects. |
| Reducer | A function that handles actions and updates state. It encapsulates all business logic for a feature. |
| Effect | An asynchronous operation that can produce actions, such as API calls or timers. |
| Store | The runtime that powers a feature, holding its state and processing actions through the reducer. |
| ViewStore | A store that specifically drives views, allowing observation of state and sending of actions. |

## API Terminology

| Term | Definition |
|------|------------|
| Endpoint | A specific URL path that represents an API resource. |
| Request | An HTTP request sent to an API endpoint. |
| Response | Data returned from an API endpoint. |
| JSON | JavaScript Object Notation, the format used for API data exchange. |
| Authentication | The process of verifying user identity. |
| Authorization | The process of determining user permissions. |
| Status Code | HTTP response codes indicating success, failure, or other status. |

## Data Model Terminology

| Term | Definition |
|------|------------|
| Model | A Swift type representing data from the API or application state. |
| Entity | A model representing a domain object in the application. |
| DTO (Data Transfer Object) | An object that carries data between processes or API boundaries. |
| Property | An attribute of a model or entity. |
| Relationship | A connection between different models or entities. |

## UI Terminology

| Term | Definition |
|------|------------|
| View | A SwiftUI component that displays UI elements. |
| Component | A reusable UI element composed of multiple views. |
| Screen | A complete view representing a full page in the app. |
| Navigation | Movement between different screens in the app. |
| State | The current condition of UI elements (distinct from TCA State). |

## Testing Terminology

| Term | Definition |
|------|------------|
| Unit Test | A test that verifies a single unit of code in isolation. |
| Integration Test | A test that verifies multiple units working together. |
| UI Test | A test that verifies the user interface and interactions. |
| Mock | A test double that simulates behavior of real objects. |
| Stub | A simplified implementation for testing purposes. |
| Assertion | A verification that a condition is true during testing. |

## Project-Specific Terminology

| Term | Definition |
|------|------------|
| Profile | A user profile containing personal information. |
| User Data | Information about a user retrieved from the API. |
| Avatar | A user's profile image. |
| Error Message | A human-readable description of an error condition. |