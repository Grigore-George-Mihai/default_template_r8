# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#tailwind_class_for" do
    {
      success: "bg-green-100",
      notice: "bg-blue-100",
      alert: "bg-red-100",
      error: "bg-red-100",
      warning: "bg-yellow-100",
      info: "bg-blue-100",
      unknown: "bg-gray-100"
    }.each do |flash_type, expected_prefix|
      it "returns a class string starting with '#{expected_prefix}' for :#{flash_type}" do
        expect(helper.tailwind_class_for(flash_type)).to include(expected_prefix)
      end
    end
  end
end
