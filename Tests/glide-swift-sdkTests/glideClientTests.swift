import XCTest
@testable import glide_sdk_swift

final class glideClient_sdkTests: XCTestCase {
    
    var client: GlideClient!

    override func setUpWithError() throws {
        super.setUp()
        client = try GlideClient()
    }

    override func tearDownWithError() throws {
        client = nil
        super.tearDown()
    }

    func testAuthenticateWithOAuth2() async throws {
        // Given
        let authConfig = AuthConfig(scopes: ["openid"], loginHint: nil, provider: .threeLeggedOAuth2)

        // When
        let response = try await client.authenticate(authConfig: authConfig)

        // Then
        XCTAssertNotNil(response.redirectUrl, "Redirect URL should not be nil.")
    }

    func testAuthenticateWithCiba() async throws {
        // Given
        let phoneNumber = "1234567890"
        let authConfig = AuthConfig(scopes: ["openid", "dpv:FraudPreventionAndDetection:sim-swap"], loginHint: "tel:\(phoneNumber)", provider: .ciba)

        // When
        let response = try await client.authenticate(authConfig: authConfig)

        // Then
        XCTAssertNotNil(response.session, "Session should not be nil.")
    }

    func testVerifyLocationSuccessfully() async throws {
        // Given
        let location = LocationBody(latitude: 37.7749, longitude: -122.4194, radius: 100, deviceId: "testDevice", deviceIdType: .phoneNumber, maxAge: 1000)

        // When
        let isValid = try await client.verifyLocation(latitude: location.latitude, longitude: location.longitude, deviceId: location.deviceId, radius: location.radius, deviceIdType: location.deviceIdType, maxAge: location.maxAge)

        // Then
        XCTAssertTrue(isValid, "Location verification should be successful.")
    }

    func testCheckSimSwap() async throws {
        // Given
        let phoneNumber = "1234567890"
        let maxAge = 0

        // When
        let isSwapped = try await client.checkSimSwap(phoneNumber: phoneNumber, maxAge: maxAge)

        // Then
        XCTAssertTrue(isSwapped, "Sim swap check should return true.")
    }
}
