# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ActiveRecord::Base
	has_many :payments

	before_save :downcase_name

	validates :name, presence: true, uniqueness: :true

	def downcase_name
		self.name = name.downcase
	end

	### Class Methods ###

	def self.categories
		Category.all.collect { |category| [category.name_label, category.id] }
	end

  def self.monthly_fee
    Category.find_by_name('monthly fee')
  end

  def self.registration_fee
    Category.find_by_name('registration fee')
  end

  def self.direct_deposit
    Category.find_by_name('direct deposit')
  end

  def self.appropriated
    Category.find_by_name('appropriated')
  end

  def self.book_fee
    Category.find_by_name('book fee')
  end

	### View Helpers ###

	def name_label
		name.titleize
	end
end
