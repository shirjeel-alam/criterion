class CriterionMail < ActiveRecord::Base
	belongs_to :mailable, :polymorphic => true

	validates :from, :presence => true
	validates :to, :presence => true
	validates :body, :presence => true
end
