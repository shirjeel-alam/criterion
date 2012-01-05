class AdminUser < ActiveRecord::Base
	DEFAULT_PASSWORD = 'criterion'
	SUPER_ADMIN, ADMIN, TEACHER, STUDENT = 0, 1, 2, 3 # Roles
	ACTIVE, DEACTIVE = true, false

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  belongs_to :user, :polymorphic => :true

  validates :role, :presence => true, :inclusion => { :in => [SUPER_ADMIN, ADMIN, TEACHER, STUDENT] }
  validates :status, :presence => true, :inclusion => { :in => [ACTIVE, DEACTIVE] }
   
  def password_required?
    new_record? ? false : super
  end

  ### Class Methods ###

  def self.roles
  	[['Super Admin', SUPER_ADMIN], ['Admin', ADMIN], ['Teacher', TEACHER], ['Student', STUDENT]]
  end

  def self.admin_roles
  	[['Super Admin', SUPER_ADMIN], ['Admin', ADMIN]]
  end

  def self.statuses
    [['Active', ACTIVE], ['Deactive', DEACTIVE]]
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
  	end
  end

  def status_label
    status ? 'Active' : 'Deactive'
  end
  
  def status_tag
  	status ? :ok : :error
  end

end
