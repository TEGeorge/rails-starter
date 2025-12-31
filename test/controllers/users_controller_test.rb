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

    assert_response :unprocessable_entity
    assert_select ".error-message"
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

    assert_response :unprocessable_entity
    assert_select ".error-message"
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

    assert_response :unprocessable_entity
    assert_select ".error-message"
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

    assert_response :unprocessable_entity
    assert_select ".error-message"
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

    assert_response :unprocessable_entity
    assert_select ".error-message"
  end

  test "should render form with errors on validation failure" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    # Should render the form, not redirect
    assert_response :unprocessable_entity
    # Should show validation errors
    assert_select ".error-message", minimum: 1
  end

  test "should reject invalid email format" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "notanemail",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error-message"
  end

  test "should reject email without domain" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          email_address: "user@",
          password: "SecurePassword123!",
          password_confirmation: "SecurePassword123!"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should accept valid email formats" do
    valid_emails = [
      "user@example.com",
      "user.name@example.com",
      "user+tag@example.co.uk",
      "user_name@example-domain.com"
    ]

    valid_emails.each do |email|
      assert_difference("User.count", 1) do
        post register_path, params: {
          user: {
            email_address: email,
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end
    end
  end

  test "signup form has HTML5 validation attributes" do
    get signup_path

    # Email field should have required and type="email"
    assert_select 'input[name="user[email_address]"][required]'
    assert_select 'input[name="user[email_address]"][type="email"]'
    assert_select 'input[name="user[email_address]"][placeholder]'

    # Password fields should have required and minlength
    assert_select 'input[name="user[password]"][required]'
    assert_select 'input[name="user[password]"][minlength="12"]'
    assert_select 'input[name="user[password]"][type="password"]'

    assert_select 'input[name="user[password_confirmation]"][required]'
    assert_select 'input[name="user[password_confirmation]"][minlength="12"]'
    assert_select 'input[name="user[password_confirmation]"][type="password"]'
  end

  test "signup form shows password requirements hint" do
    get signup_path

    assert_select ".label-text-alt", text: "Minimum 12 characters"
  end
end
