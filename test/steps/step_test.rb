# frozen_string_literal: true

class StepTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_apply
    response = Response.new('foo', {})
    next_step = Object.new

    def next_step.apply(response)
      response.object * 2
    end

    assert_equal 'foofoo', Step.new(next_step).apply(response)
  end
end
