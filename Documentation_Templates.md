# Swift Documentation Templates

This file provides templates for consistent documentation comments throughout the codebase.

## Class/Struct/Enum Documentation Template

```swift
/// A brief description of the type.
///
/// A more detailed description that explains the purpose and functionality
/// of this type. Include any important details about how to use it.
struct/class/enum TypeName {
    // Implementation
}
```

## Function Documentation Template

```swift
/// A brief description of what the function does.
///
/// A more detailed description of the function's purpose, behavior, and any
/// special considerations when using it.
///
/// - Parameter paramName: Description of the parameter.
/// - Returns: Description of what the function returns.
/// - Throws: Description of the errors that can be thrown (if applicable).
///
/// - Example:
/// ```swift
/// // Example usage of the function
/// let result = myFunction(param: value)
/// ```
func myFunction(param: ParamType) -> ReturnType {
    // Implementation
}
```

## Property Documentation Template

```swift
/// A description of what this property represents.
///
/// Include additional details about the property's purpose, behavior,
/// or any side effects of accessing it.
var propertyName: PropertyType
```

## Computed Property Documentation Template

```swift
/// A description of what this computed property represents.
///
/// Include details about how the property is calculated and any
/// side effects of accessing it.
///
/// - Returns: Description of the value returned.
var computedProperty: PropertyType {
    // Implementation
}
```

## Extension Documentation Template

```swift
/// Extension providing additional functionality to TypeName.
///
/// Describe the general purpose of this extension and what capabilities
/// it adds to the extended type.
extension TypeName {
    // Implementation
}
```

## Protocol Documentation Template

```swift
/// A brief description of the protocol's purpose.
///
/// A more detailed description of what conforming types should implement
/// and the behavior expected of them.
protocol ProtocolName {
    // Requirements
}
```

## Documentation Best Practices

1. **Be Concise**: Keep descriptions clear and to the point.
2. **Use Complete Sentences**: Start with a capital letter and end with a period.
3. **Describe Parameters Thoroughly**: Explain what each parameter is for and any constraints.
4. **Document Throws Clauses**: List all possible errors that can be thrown.
5. **Include Examples**: For complex functions or types, provide usage examples.
6. **Document Side Effects**: Mention any side effects a function might have.
7. **Use Markdown**: Use formatting like *italics*, **bold**, `code`, and code blocks where appropriate.
8. **Keep Documentation Updated**: Update documentation when code changes.