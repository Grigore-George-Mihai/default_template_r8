# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, %i[user admin], validate: true

  with_options presence: true do
    validates :first_name, :last_name
  end
end
