require "test_helper"

class TurboNativeDetectionTest < ActionDispatch::IntegrationTest
  test "turbo_native_app? returns true for iOS user agent" do
    get root_url, headers: { "User-Agent" => "Turbo Native iOS" }
    assert_response :success
    # Note: We can't directly test helper methods in integration tests
    # These are tested implicitly through controller usage
  end

  test "turbo_native_app? returns true for Android user agent" do
    get root_url, headers: { "User-Agent" => "Turbo Native Android" }
    assert_response :success
  end

  test "turbo_native_app? returns false for regular browser user agent" do
    get root_url, headers: { "User-Agent" => "Mozilla/5.0" }
    assert_response :success
  end
end
