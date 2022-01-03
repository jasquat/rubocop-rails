# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ConvertActiveRecordHashesToArel, :config do
  context 'all' do
    it 'can convert simple all method' do
      expect_offense(<<~RUBY)
        User.all(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `all`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component)
      RUBY
    end

    it 'can convert simple all method with nil receiver' do
      expect_offense(<<~RUBY)
        all(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `all`.
      RUBY

      expect_correction(<<~RUBY)
        includes(:component)
      RUBY
    end

    it 'can convert with multiple keys' do
      expect_offense(<<~RUBY)
        User.all(:include => :component, :conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `all`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah'])
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.all(:include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `all`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).do_not_touch_this_method
      RUBY
    end
  end

  context 'paginate' do
    it 'can convert simple paginate method' do
      expect_offense(<<~RUBY)
        User.paginate(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `paginate`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component)
      RUBY
    end

    it 'can convert simple paginate method with nil receiver' do
      expect_offense(<<~RUBY)
        paginate(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `paginate`.
      RUBY

      expect_correction(<<~RUBY)
        includes(:component)
      RUBY
    end

    it 'can convert with multiple keys' do
      expect_offense(<<~RUBY)
        User.paginate(:include => :component, :conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `paginate`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah'])
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.paginate(:include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `paginate`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).do_not_touch_this_method
      RUBY
    end
  end

  context 'find' do
    it 'can convert simple all method' do
      expect_offense(<<~RUBY)
        User.find(:all, :include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component)
      RUBY
    end

    it 'can convert simple all method with nil receiver' do
      expect_offense(<<~RUBY)
        find(:all, :include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        includes(:component)
      RUBY
    end

    it 'can convert with multiple keys' do
      expect_offense(<<~RUBY)
        User.find(:all, :include => :component, :conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah'])
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.find(:all, :include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).do_not_touch_this_method
      RUBY
    end
  end

  context 'first' do
    it 'can convert simple first method' do
      expect_offense(<<~RUBY)
        User.first(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `first`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).first
      RUBY
    end

    it 'can convert simple first method with nil receiver' do
      expect_offense(<<~RUBY)
        first(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `first`.
      RUBY

      expect_correction(<<~RUBY)
        includes(:component).first
      RUBY
    end

    it 'can convert with conditions only' do
      expect_offense(<<~RUBY)
        User.first(:conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `first`.
      RUBY

      expect_correction(<<~RUBY)
        User.find_by(['hello = ?', 'blah'])
      RUBY
    end

    it 'can convert with multiple keys with conditions' do
      expect_offense(<<~RUBY)
        User.first(:include => :component, :conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `first`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).find_by(['hello = ?', 'blah'])
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.first(:include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `first`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).find_by(['hello = ?', 'blah']).do_not_touch_this_method
      RUBY
    end
  end

  context 'count' do
    it 'can convert simple count method' do
      expect_offense(<<~RUBY)
        User.count(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).count
      RUBY
    end

    it 'can convert simple count method with nil receiver' do
      expect_offense(<<~RUBY)
        count(:include => :component)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        includes(:component).count
      RUBY
    end

    it 'can convert with conditions only' do
      expect_offense(<<~RUBY)
        User.count(:conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.where(['hello = ?', 'blah']).count
      RUBY
    end

    it 'can convert with multiple keys with conditions' do
      expect_offense(<<~RUBY)
        User.count(:include => :component, :conditions => ['hello = ?', 'blah'])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).count
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.count(:include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).count.do_not_touch_this_method
      RUBY
    end

    it 'can convert with multiple keys, mutiple methods, and symbol arg' do
      expect_offense(<<~RUBY)
        User.count(:id, :include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).count(:id).do_not_touch_this_method
      RUBY
    end

    it 'can convert with multiple keys, mutiple methods, and string arg' do
      expect_offense(<<~RUBY)
        User.count('distinct(id)', :include => :component, :conditions => ['hello = ?', 'blah']).do_not_touch_this_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arel` instead of `count`.
      RUBY

      expect_correction(<<~RUBY)
        User.includes(:component).where(['hello = ?', 'blah']).count('distinct(id)').do_not_touch_this_method
      RUBY
    end
  end

  context 'find_with_symbol' do
    it 'can convert simple all method' do
      expect_offense(<<~RUBY)
        User.find(:all)
        ^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.all
      RUBY
    end

    it 'can convert simple first method' do
      expect_offense(<<~RUBY)
        User.find(:first)
        ^^^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.first
      RUBY
    end

    it 'can convert with multiple keys and mutiple methods' do
      expect_offense(<<~RUBY)
        User.find(:all).do_not_touch_this_method
        ^^^^^^^^^^^^^^^ Use `arel` instead of `find`.
      RUBY

      expect_correction(<<~RUBY)
        User.all.do_not_touch_this_method
      RUBY
    end
  end
end
