ActiveAdmin.register CriterionAccount do
  menu :parent => 'Criterion', :priority => 2, :if => proc { current_admin_user.super_admin? }

  index do
  	column 'ID', :sortable => :id do |account|
      link_to(account.id, admin_criterion_account_path(account))
    end
    column 'Account Holder', :sortable => :admin_user_id do |account|
    	admin = account.admin_user
    	case admin.role
      when AdminUser::TEACHER
        link_to(admin.user.name, admin_teacher_path(admin.user)) rescue nil
      when AdminUser::STUDENT
        link_to(admin.user.name, admin_student_path(admin.user)) rescue nil
      else
      	link_to(admin.email, admin_admin_user_path(admin))
      end
    end
    column 'Initial Balance', :sortable => :balance do |account|
    	number_to_currency(account.balance, :unit => 'Rs. ', :precision => 0)
    end

    default_actions
  end

  show :title => :title do
  	panel 'Criterion Account Details' do
      attributes_table_for criterion_account do
        row(:id) { criterion_account.id }
        row(:account_holder) do 
        	admin = criterion_account.admin_user
    			case admin.role
      		when AdminUser::TEACHER
        		link_to(admin.user.name, admin_teacher_path(admin.user)) rescue nil
      		when AdminUser::STUDENT
        		link_to(admin.user.name, admin_student_path(admin.user)) rescue nil
      		else
      			link_to(admin.email, admin_admin_user_path(admin))
      		end
	      end
        row(:initial_balance) { number_to_currency(criterion_account.balance, :unit => 'Rs. ', :precision => 0) }
      end
    end

    active_admin_comments
  end
end
