# frozen_string_literal: true

class Writer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable
  has_many :learning_stocks, dependent: :destroy
end
