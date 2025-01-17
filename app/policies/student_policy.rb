class StudentPolicy < ApplicationPolicy
  attr_reader :user, :student

  def initialize(user, student)
    @user = user
    @student = student
  end

  def show?
    user.id == student.user_id
  end

  def update?
    user.id == student.user_id
  end

  def destroy?
    user.id == student.user_id
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
