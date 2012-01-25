class Category < ActiveRecord::Base
	STUDENT_FEE = 'student fee'
	TEACHER_FEE = 'teacher fee'
	BILLS = 'bills'
	MISC = 'misc'

	has_many :payments

	before_save :downcase_name

	validates :name, :presence => true, :uniqueness => :true

	def downcase_name
		self.name = name.downcase
	end

	### Class Methods ###

	def self.categories
		Category.all.collect { |category| [category.name_label, category.id] }
	end

	### View Helpers ###

	def name_label
		name.titleize
	end
end
