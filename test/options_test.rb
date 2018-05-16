# frozen_string_literal: true

class OptionsTest < Minitest::Test
  include AdequateSerialization::Options

  def test_wraps_includes
    opts = opts_for(includes: :foo)
    includes = opts.includes

    assert_kind_of Array, includes
    assert_equal :foo, includes.first
  end

  def test_keeps_other_options
    opts = opts_for(foo: 'bar')

    assert_equal 'bar', opts.options[:foo]
  end

  def test_multi_caching?
    opts = opts_for(multi_caching: true)

    assert opts.multi_caching?
  end

  def test_cache_key_for_no_includes
    opts = opts_for
    object = Object.new

    assert_equal object, opts.cache_key_for(object)
  end

  def test_cache_key_with_one_include
    opts = opts_for(includes: :foo)
    object = Object.new

    assert_equal [object, :foo], opts.cache_key_for(object)
  end

  def test_cache_key_with_multiple_includes
    opts = opts_for(includes: %i[foo bar])
    object = Object.new

    assert_equal [object, :foo, :bar], opts.cache_key_for(object)
  end

  def test_from_nothing_passed
    assert_kind_of Opts, AdequateSerialization::Options.from
  end

  def test_from_some_options_passed
    opts = AdequateSerialization::Options.from(includes: :foo)

    assert_kind_of Opts, opts
    assert_equal %i[foo], opts.includes
  end

  def test_null
    opts = AdequateSerialization::Options.null

    assert_kind_of NullOpts, opts
    assert_empty opts.includes
  end

  private

  def opts_for(**options)
    AdequateSerialization::Options::Opts.new(**options)
  end
end
