# APICallsWithTCA

A demonstration project showcasing API integration using The Composable Architecture (TCA) in iOS. This project implements a user profile viewer that fetches and displays user data from reqres.in API while following modern Swift development practices.

## Features

- User profile viewing with pagination
- Async/await API integration
- Clean architecture using TCA
- Comprehensive error handling
- Loading states and user feedback
- Modern SwiftUI implementation

## Project Structure

### 1. Data Models (`APIModels.swift`)

```swift
// API Response wrapper
struct SingleUser: Decodable {
    var data: UserData
}

// Main user data model
struct UserData: Decodable, Equatable {
    var id: Int
    var email: String
    var firstName: String
    var lastName: String
    var avatar: String
}

// Error handling
enum UserError: String, Equatable, Error {
    case serverError
    case invalidUser
    case invalidUrl
    case internalError
}
```

### 2. API Configuration (`APIConfig.swift`)

- Handles all network communications
- Implements async/await for API calls
- Manages HTTP status codes and errors
- Handles JSON decoding and data transformation
- URLSession cache management

### 3. UI Layer (`ProfileView.swift`)

#### ProfileFeature (Reducer)
- State Management
  * User ID tracking
  * Error message handling
  * API response storage

#### ProfileView (SwiftUI)
- User interface components
- Navigation controls
- Async image loading
- Loading states
- Error displays

## Technical Implementation

### Architecture

- **The Composable Architecture (TCA)**
  * State management
  * Action handling
  * Side effect management
  * Unidirectional data flow

### Modern Swift Features

- Async/await for asynchronous operations
- Result type for error handling
- Codable for JSON parsing
- SwiftUI for declarative UI
- Computed properties
- Custom error handling

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/gangadharrr/APICallsWithTCA.git
```

2. Open the project in Xcode:
```bash
cd APICallsWithTCA
open APICallsWithTCA.xcodeproj
```

3. Install dependencies if required (using SPM)

4. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- The Composable Architecture package

## Best Practices

1. **Clean Architecture**
   - Separation of concerns
   - Modular component design
   - Clear responsibility boundaries

2. **Error Handling**
   - Type-safe error handling
   - User-friendly error messages
   - Comprehensive error cases

3. **Performance**
   - Efficient memory management
   - URLSession cache control
   - Optimized state updates

4. **User Experience**
   - Intuitive navigation
   - Loading state indicators
   - Clear error feedback
   - Responsive UI

## API Integration

This project uses the [reqres.in](https://reqres.in/) API for demonstration purposes. The API provides mock user data for testing and development.

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

[gangadharrr](https://github.com/gangadharrr)
