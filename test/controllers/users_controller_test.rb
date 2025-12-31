require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get signup page" do
    get signup_path
    assert_response :success
    assert_select "form"
  end

  test "should create user with valid parameters" do
    assert_difference("User.count", 1) do
      post register_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_equal "User created successfully", flash[:notice]

    # Verify user was created with correct email
    user = User.find_by(email_address: "newuser@example.com")
    assert_not_nil user
    assert_equal "newuser@example.com", user.email_address

    # Verify session was started
    assert_not_nil cookies[:session_id]
    assert_equal 1, user.sessions.count
  end

  test "should normalize email address on registration" do
    post register_path, params: {
      user: {
        email_address: "  UPPERCASE@EXAMPLE.COM  ",
        password: "SecurePassword123!",
        password_confirmation: "SecurePassword123!"
      }
    }

    user = User.find_by(email_address: "uppercase@example.com")
    assert_not_nil user
    assert_equal "uppercase@example.com", user.email_address
  end

  test "should not create user with mismatched password confirmation" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "test@example.com",
          password: "SecurePassword123!",
          password_confirmation: "DifferentPassword123!"
        }
      }
    end

    assert_redirected_to signup_path
    follow_redirect!
    assert_equal "Failed to create user", flash[:alert]
  end

  test "should not create user with duplicate email address" do
    # Create first user
    User.create!(
      email_address: "duplicate@example.com",
      password: "SecurePassword123!",
      password_confirmation: "SecurePassword123!"
    )

    # Try to create second user with same email
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "duplicate@example.com",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_redirected_to signup_path
    follow_redirect!
    assert_equal "Failed to create user", flash[:alert]
  end

  test "should not create user without email address" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_redirected_to signup_path
    follow_redirect!
    assert_equal "Failed to create user", flash[:alert]
  end

  test "should not create user without password" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "test@example.com",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_redirected_to signup_path
    follow_redirect!
    assert_equal "Failed to create user", flash[:alert]
  end

  test "should handle duplicate email with different case" do
    # Create first user
    User.create!(
      email_address: "user@example.com",
      password: "SecurePassword123!",
      password_confirmation: "SecurePassword123!"
    )

    # Try to create second user with same email in different case
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "USER@EXAMPLE.COM",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_redirected_to signup_path
    follow_redirect!
    assert_equal "Failed to create user", flash[:alert]
  end
end
