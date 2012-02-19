class AdminUser < ActiveRecord::Base
	DEFAULT_PASSWORD = 'criterion'
	SUPER_ADMIN, ADMIN, TEACHER, STUDENT, STAFF, PARTNER = 0, 1, 2, 3, 4, 5
	ACTIVE, DEACTIVE = true, false

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  belongs_to :user, :polymorphic => :true
  has_many :criterion_mails, :as => :mailable
  has_many :sent_messages, :as => :sender, :class_name => 'CriterionSms'
  has_one :criterion_account

  validates :role, :presence => true, :inclusion => { :in => [SUPER_ADMIN, ADMIN, TEACHER, STUDENT, STAFF, PARTNER] }

  after_create { |admin| admin.build_criterion_account.save! }

  scope :admin, where(:role => [ADMIN, SUPER_ADMIN, PARTNER])
   
  def password_required?
    new_record? ? false : super
  end

  def super_admin?
    role == SUPER_ADMIN
  end

  def admin?
    role == ADMIN
  end

  def teacher?
    role == TEACHER
  end

  def student?
    role == STUDENT
  end

  def staff?
    role == STAFF
  end

  def partner?
    role == PARTNER
  end

  def super_admin_or_partner?
    super_admin? || partner?
  end

  ### Class Methods ###

  def self.roles
  	[['Super Admin', SUPER_ADMIN], ['Admin', ADMIN], ['Teacher', TEACHER], ['Student', STUDENT], ['Staff', STAFF], ['Partner', PARTNER]]
  end

  def self.admin_roles
  	[['Super Admin', SUPER_ADMIN], ['Admin', ADMIN], ['Partner', PARTNER]]
  end

  def self.statuses
    [['Active', ACTIVE], ['Deactive', DEACTIVE]]
  end

  def self.emails
    AdminUser.admin.collect(&:email)
  end

  ### View Helpers ###

  def role_label
  	case role
	  	when SUPER_ADMIN
	  		'Super Admin'
	  	when ADMIN
	  		'Admin'
	  	when TEACHER
	  		'Teacher'
	  	when STUDENT
	  		'Student'
      when STAFF
        'Staff'
      when PARTNER
        'partner'
  	end
  end

  def status_label
    status ? 'Active' : 'Deactive'
  end
  
  def status_tag
  	status ? :ok : :error
  end
end
