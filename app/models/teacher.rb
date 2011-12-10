class Teacher < ActiveRecord::Base
  has_many :courses
  has_many :payments, :through => :courses
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy

  ### Class Methods ###

  def self.teachers
    Teacher.all.collect { |teacher| [teacher.name, teacher.id] }
  end
end
