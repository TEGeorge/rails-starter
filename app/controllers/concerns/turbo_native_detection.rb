module TurboNativeDetection
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_native_app?
    helper_method :turbo_ios_app?
    helper_method :turbo_android_app?
  end

  def turbo_native_app?
    request.user_agent.to_s.match?(/(Turbo Native iOS|Turbo Native Android)/)
  end

  def turbo_ios_app?
    request.user_agent.to_s.match?(/Turbo Native iOS/)
  end

  def turbo_android_app?
    request.user_agent.to_s.match?(/Turbo Native Android/)
  end
end
