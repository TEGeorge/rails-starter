# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/hotwire-native-bridge", to: "https://cdn.jsdelivr.net/npm/@hotwired/hotwire-native-bridge@1.0.0/dist/hotwire-native-bridge.umd.js"
pin_all_from "app/javascript/controllers", under: "controllers"
