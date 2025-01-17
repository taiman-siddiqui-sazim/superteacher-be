require "test_helper"

class StudentPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @student = students(:one)
    @other_user = users(:two)
    @other_student = students(:two)
  end

  def test_scope
    scope = Pundit.policy_scope(@user, Student)
    assert_equal [ @student ], scope.to_a
  end

  def test_show
    policy = StudentPolicy.new(@user, @student)
    assert policy.show?

    policy = StudentPolicy.new(@user, @other_student)
    assert_not policy.show?
  end

  def test_update
    policy = StudentPolicy.new(@user, @student)
    assert policy.update?

    policy = StudentPolicy.new(@user, @other_student)
    assert_not policy.update?
  end

  def test_destroy
    policy = StudentPolicy.new(@user, @student)
    assert policy.destroy?

    policy = StudentPolicy.new(@user, @other_student)
    assert_not policy.destroy?
  end
end
