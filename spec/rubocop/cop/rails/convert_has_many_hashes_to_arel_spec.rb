# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ConvertHasManyHashesToArel, :config do
  context 'has_many' do
    it 'can convert simple all method' do
      expect_offense(<<~RUBY)
        has_many :things, conditions: 'sharp = 0'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of hash with options.
      RUBY

      expect_correction(<<~RUBY)
        has_many :things, -> { where('sharp = 0') }
      RUBY
    end

    it 'can convert with multiple keys' do
      expect_offense(<<~RUBY)
        has_many :things, class_name: 'ClassName', conditions: 'sharp = 0', include: {relation1: {relation_class: [:language, :level]}}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of hash with options.
      RUBY

      expect_correction(<<~RUBY)
        has_many :things, -> { where('sharp = 0').includes({relation1: {relation_class: [:language, :level]}}) }, class_name: 'ClassName'
      RUBY
    end

    it 'can convert with multiple keys and hash rockets' do
      expect_offense(<<~RUBY)
        has_many :things, :class_name => 'ClassName', :conditions => 'sharp = 0', :include => {:relation1 => {:relation_class => [:language, :level]}}
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of hash with options.
      RUBY

      expect_correction(<<~RUBY)
        has_many :things, -> { where('sharp = 0').includes({:relation1 => {:relation_class => [:language, :level]}}) }, :class_name => 'ClassName'
      RUBY
    end

    it 'skips non-arel options' do
      expect_no_offenses(<<~RUBY)
        has_many :things_more, :class_name => "ClassName::Using::HashRockets"
      RUBY

      expect_no_offenses(<<~RUBY)
        has_many :things, class_name: 'ClassName::NotUsing::HashRockets'
      RUBY
    end
  end
end
