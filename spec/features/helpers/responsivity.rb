# frozen_string_literal: true

module Responsivity
  def resize_window_to_mobile
    resize_window_by([640, 480])
  end

  def resize_window_to_tablet
    resize_window_by([960, 640])
  end

  def resize_window_default
    resize_window_by([1024, 768])
  end

  private

  def resize_window_by(size)
    return unless Capybara.current_session.driver.browser.respond_to? 'manage'

    Capybara.current_session.driver.browser.manage.window.resize_to(size[0], size[1])
  end
end
