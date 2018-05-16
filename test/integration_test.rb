# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < Minitest::Test
  EXPECTED = [
    { id: 1, name: 'Clark Kent', title: 'Superman', age: 29 },
    { id: 2, name: 'Bruce Wayne', title: 'Batman', age: 40 },
    { id: 3, name: 'Barry Allen', title: 'The Flash', age: 28 },
    { id: 4, name: 'Diana Prince', title: 'Wonder Woman', age: 25 }
  ].freeze

  def test_everything
    ages = {}

    users =
      EXPECTED.map do |attributes|
        ages[attributes[:id]] = attributes[:age]
        User.new(**attributes.dup.tap { |duped| duped.delete(:age) })
      end

    users.map! { |user| user.as_json(includes: :title, attach: { age: ages }) }
    assert_equal EXPECTED, users
  end
end
