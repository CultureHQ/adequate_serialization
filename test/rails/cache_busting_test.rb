# frozen_string_literal: true

require 'test_helper'

class CacheBustingTest < Minitest::Test
  include AdequateSerialization::CacheBusting

  class Customer < ApplicationRecord
    has_many :products, inverse_of: :customer
  end

  class Product < ApplicationRecord
    belongs_to :customer, inverse_of: :products
    belongs_to :no_inverse

    has_many :product_tags
    has_many :tags, through: :product_tags
  end

  class ProductTag < ApplicationRecord
    belongs_to :product
    belongs_to :tags
  end

  class Tag < ApplicationRecord
    has_many :product_tags
    has_many :products, through: :product_tags
  end

  class CustomerSerializer < AdequateSerialization::Serializer; end

  class ProductSerializer < AdequateSerialization::Serializer; end

  def test_touch_not_found
    assert_raises TouchNotFoundError do
      CustomerSerializer.attribute :products
    end
  end

  def test_active_job_not_found
    without_active_job do
      assert_raises ActiveJobNotFoundError do
        ProductSerializer.attribute :customer
      end
    end
  end

  def test_belongs_to_inverse_not_found
    assert_raises InverseNotFoundError do
      ProductSerializer.attribute :no_inverse
    end
  end

  def test_has_many_inverse_not_found
    assert_raises InverseNotFoundError do
      ProductSerializer.attribute :tags
    end
  end

  private

  def without_active_job
    active_job = ActiveJob
    Object.send(:remove_const, :ActiveJob)

    begin
      yield
    ensure
      Object.const_set(:ActiveJob, active_job)
    end
  end
end
