require "test_helper"

class Turbo::Ios::PathConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get turbo_ios_path_configuration_url(format: :json)
    assert_response :success
  end

  test "should return valid JSON structure" do
    get turbo_ios_path_configuration_url(format: :json)

    json_response = JSON.parse(response.body)

    assert json_response.key?("settings"), "Response should have settings key"
    assert json_response.key?("rules"), "Response should have rules key"
    assert_kind_of Array, json_response["rules"], "Rules should be an array"
  end

  test "should return modal presentation rule for new and edit paths" do
    get turbo_ios_path_configuration_url(format: :json)

    json_response = JSON.parse(response.body)
    modal_rule = json_response["rules"].find { |rule| rule["patterns"]&.include?("/new$") }

    assert modal_rule, "Should have a rule for /new$ pattern"
    assert_equal "modal", modal_rule.dig("properties", "presentation")
  end

  test "should set correct content type" do
    get turbo_ios_path_configuration_url(format: :json)
    assert_equal "application/json; charset=utf-8", response.content_type
  end
end
