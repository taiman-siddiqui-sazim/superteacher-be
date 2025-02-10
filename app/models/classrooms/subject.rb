module Classrooms
    class Subject < ApplicationRecord
      validates :subject, presence: true, uniqueness: true
    end
end
