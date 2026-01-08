module Turbo
  module Ios
    class PathConfigurationsController < ApplicationController
      # Allow unauthenticated access for path configuration
      allow_unauthenticated_access

      def show
        render json: {
          settings: {
            # App-level settings can be added here
          },
          rules: [
            {
              patterns: [ "/new$", "/edit$" ],
              properties: {
                presentation: "modal"
              }
            },
            {
              patterns: [ "/signup$", "/login$" ],
              properties: {
                presentation: "modal"
              }
            }
          ]
        }
      end
    end
  end
end
