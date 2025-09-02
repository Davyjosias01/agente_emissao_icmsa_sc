#frozen_string_literal: true
module Agent
  module Support
    class Playwright
      def self.open
        require "playwright"
        Playwright.create do |pw|
          browser = (ENV["BROWSER"] || "chromium").to_sym
          headless = ENV.fetch("HEADLESS", "true") == "true"
          timeout_ms = ENV.fetch("PW_TIMEOUT_MS", "20000").to_i

          pw.public_send(browser).launch(headless: headless) do |br|
            br.new_context(accept_downloads: true) do |ctx|
              ctx.set_default_timeout(timeout_ms)
              ctx.new_page { |page| yield page }
            end
          end
        end
      end
    end
  end
end