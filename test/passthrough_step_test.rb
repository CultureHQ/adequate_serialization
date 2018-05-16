# frozen_string_literal: true

class PassthroughStepTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_last_step
    current = Object.new
    response = Response.new(Object.new, {}, current)

    assert_equal current, LastStep.new.apply(response)
  end

  def test_passthrough_step
    response = Response.new(Object.new, {}, 'foo')
    next_step = Object.new

    def next_step.apply(response)
      response.current * 2
    end

    assert_equal 'foofoo', PassthroughStep.new(next_step).apply(response)
  end
end
