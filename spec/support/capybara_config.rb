# frozen_string_literal: true

# System specs run in headless Chrome (Selenium Manager fetches a matching chromedriver).
# Failure screenshots go to tmp/capybara, which CI uploads as an artifact.
Capybara.enable_aria_label = true

# Chrome's password manager / breach-detection bubble lives outside the page, survives Capybara's
# per-example reset, and can steal focus from the next example's form after a sign-in with a
# well-known test password ("Password123!"). Turn it off for the test browser.
CHROME_TEST_OPTIONS = lambda do |options|
  options.add_preference("credentials_enable_service", false)
  options.add_preference("profile.password_manager_enabled", false)
  options.add_preference("profile.password_manager_leak_detection", false)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400], &CHROME_TEST_OPTIONS
  end

  # Tag a system spec with `:mobile` to run it at phone size. It uses its own named driver,
  # so the window size never leaks into desktop specs that share the browser session.
  config.before(:each, :mobile, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [390, 844],
                         options: { name: :headless_chrome_mobile }, &CHROME_TEST_OPTIONS
  end
end
