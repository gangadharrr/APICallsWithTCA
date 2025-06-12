import XCTest
@testable import APICallsWithTCA

// Mock implementation of the UserService for testing
class MockUserService: UserServiceProtocol {
    var mockResult: Result<UserData, UserError>?
    
    func getUser(id: Int) async throws -> Result<UserData, UserError> {
        if let result = mockResult {
            return result
        }
        throw UserError.serverError
    }
}

final class UserControllerTests: XCTestCase {
    var mockUserService: MockUserService!
    var userController: UserController!
    
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        userController = UserController(userService: mockUserService)
    }
    
    override func tearDown() {
        mockUserService = nil
        userController = nil
        super.tearDown()
    }
    
    func testFetchUserSuccess() async {
        // Given
        let mockUser = UserData(id: 1, email: "test@example.com", firstName: "John", lastName: "Doe", avatar: "https://example.com/avatar.jpg")
        mockUserService.mockResult = .success(mockUser)
        
        // When
        let result = await userController.fetchUser(id: 1)
        
        // Then
        switch result {
        case .success(let userData):
            XCTAssertEqual(userData.id, 1)
            XCTAssertEqual(userData.email, "test@example.com")
            XCTAssertEqual(userData.fullName, "John Doe")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testFetchUserFailure() async {
        // Given
        mockUserService.mockResult = .failure(.invalidUser)
        
        // When
        let result = await userController.fetchUser(id: 999)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .invalidUser)
        }
    }
    
    func testGetNextUserId() {
        // Given
        let currentId = 5
        
        // When
        let nextId = userController.getNextUserId(currentId: currentId)
        
        // Then
        XCTAssertEqual(nextId, 6)
    }
    
    func testGetPreviousUserId() {
        // Given
        let currentId = 5
        
        // When
        let previousId = userController.getPreviousUserId(currentId: currentId)
        
        // Then
        XCTAssertEqual(previousId, 4)
    }
    
    func testGetPreviousUserIdMinimum() {
        // Given
        let currentId = 1
        
        // When
        let previousId = userController.getPreviousUserId(currentId: currentId)
        
        // Then
        XCTAssertEqual(previousId, 1, "ID should not go below 1")
    }
    
    func testGetInitialUserId() {
        // When
        let initialId = userController.getInitialUserId()
        
        // Then
        XCTAssertEqual(initialId, 1)
    }
}