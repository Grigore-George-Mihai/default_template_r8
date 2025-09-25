# frozen_string_literal: true

module ApplicationHelper
  def tailwind_class_for(flash_type)
    {
      success: "bg-green-100 border-green-400 text-green-800",
      notice: "bg-blue-100 border-blue-400 text-blue-800",
      alert: "bg-red-100 border-red-400 text-red-800",
      error: "bg-red-100 border-red-400 text-red-800",
      warning: "bg-yellow-100 border-yellow-400 text-yellow-800",
      info: "bg-blue-100 border-blue-400 text-blue-800"
    }.fetch(flash_type.to_sym, "bg-gray-100 border-gray-400 text-gray-800")
  end
end
