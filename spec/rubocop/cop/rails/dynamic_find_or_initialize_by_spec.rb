# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DynamicFindOrInitializeBy, :config do
  let(:cop_config) do
    { 'AllowedMethods' => %w[find_or_initialize_by_sql] }
  end

  context 'with dynamic find_or_initialize_by_*' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name(name)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name`.
      RUBY

      expect_correction(<<~RUBY)
        User.find_or_initialize_by(name: name)
      RUBY
    end
  end

  context 'with dynamic find_or_initialize_by_*_and_*' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name_and_email(name, email)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name_and_email`.
      RUBY

      expect_correction(<<~RUBY)
        User.find_or_initialize_by(name: name, email: email)
      RUBY
    end
  end

  context 'with dynamic find_or_initialize_by_*_and_*_and_*' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name_and_email_and_token(name, email, token)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name_and_email_and_token`.
      RUBY

      expect_correction(<<~RUBY)
        User.find_or_initialize_by(name: name, email: email, token: token)
      RUBY
    end
  end

  context 'with dynamic find_or_initialize_by_*_and_*_and_* with newline' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name_and_email_and_token(
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name_and_email_and_token`.
          name,
          email,
          token
        )
      RUBY

      expect_correction(<<~RUBY)
        User.find_or_initialize_by(
          name: name,
          email: email,
          token: token
        )
      RUBY
    end
  end

  context 'with column includes underscore' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_first_name(name)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_first_name`.
      RUBY

      expect_correction(<<~RUBY)
        User.find_or_initialize_by(first_name: name)
      RUBY
    end
  end

  context 'with too much arguments' do
    it 'registers an offense and no corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name_and_email(name, email, token)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name_and_email`.
      RUBY

      expect_no_corrections
    end
  end

  context 'with too few arguments' do
    it 'registers an offense and no corrects' do
      expect_offense(<<~RUBY)
        User.find_or_initialize_by_name_and_email(name)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name_and_email`.
      RUBY

      expect_no_corrections
    end
  end

  it 'accepts splat argument' do
    expect_no_offenses('User.find_or_initialize_by_scan(*args)')
  end

  it 'accepts any of the arguments are splat argument' do
    expect_no_offenses('User.find_or_initialize_by_foo_and_bar(arg, *args)')
  end

  it 'accepts dynamic finder with single hash argument' do
    expect_no_offenses('Post.find_or_initialize_by_id(limit: 1)')
  end

  it 'accepts dynamic finder with multiple arguments including hash' do
    expect_no_offenses('Post.find_or_initialize_by_title_and_id("foo", limit: 1)')
  end

  context 'with no receiver' do
    it 'does not register an offense when not inheriting any class' do
      expect_no_offenses(<<~RUBY)
        class C
          def do_something
            find_or_initialize_by_name(name)
          end
        end
      RUBY
    end

    it 'does not register an offense when not inheriting `ApplicationRecord`' do
      expect_no_offenses(<<~RUBY)
        class C < Foo
          def do_something
            find_or_initialize_by_name(name)
          end
        end
      RUBY
    end

    it 'registers an offense when inheriting `ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ApplicationRecord
          def do_something
            find_or_initialize_by_name(name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name`.
          end
        end
      RUBY
    end

    it 'registers an offense when inheriting `ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ActiveRecord::Base
          def do_something
            find_or_initialize_by_name(name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name`.
          end
        end
      RUBY
    end
  end

  context 'when using safe navigation operator' do
    context 'with dynamic find_or_initialize_by_*' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          user&.find_or_initialize_by_name(name)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `find_or_initialize_by` instead of dynamic `find_or_initialize_by_name`.
        RUBY

        expect_correction(<<~RUBY)
          user&.find_or_initialize_by(name: name)
        RUBY
      end
    end
  end
end
