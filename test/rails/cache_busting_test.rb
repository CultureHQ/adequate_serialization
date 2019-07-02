# frozen_string_literal: true

require 'test_helper'

class CacheBustingTest < Minitest::Test
  include AdequateSerialization::CacheBusting

  class Org < ApplicationRecord
    has_many :users, inverse_of: :org
  end

  class User < ApplicationRecord
    belongs_to :org, inverse_of: :users
    belongs_to :special_org
  end

  class OrgSerializer < AdequateSerialization::Serializer; end

  class UserSerializer < AdequateSerialization::Serializer; end

  def test_touch_not_found
    assert_raises TouchNotFoundError do
      OrgSerializer.attribute :users
    end
  end

  def test_active_job_not_found
    without_active_job do
      assert_raises ActiveJobNotFoundError do
        UserSerializer.attribute :org
      end
    end
  end

  def test_inverse_not_found
    assert_raises InverseNotFoundError do
      UserSerializer.attribute :special_org
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
