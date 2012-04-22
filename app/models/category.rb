# == Schema Information
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
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
