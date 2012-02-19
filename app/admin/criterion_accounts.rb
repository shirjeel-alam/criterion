ActiveAdmin.register CriterionAccount do
  menu :parent => 'Criterion', :priority => 2, :if => proc { current_admin_user.super_admin? }

  index do
  	column 'ID', :sortable => :id do |account|
      link_to(account.id, admin_criterion_account_path(account))
    end
    column 'Account Holder', :sortable => :admin_user_id do |account|
    	account_holder = account.admin_user
    	case account_holder.role
      when AdminUser::TEACHER
        link_to(account_holder.user.name, admin_teacher_path(account_holder.user)) rescue nil
      when AdminUser::STAFF
        link_to(account_holder.user.name, admin_staff_path(account_holder.user)) rescue nil
      when AdminUser::STUDENT
        link_to(account_holder.user.name, admin_student_path(account_holder.user)) rescue nil
      else
      	link_to(account_holder.email, admin_admin_user_path(account_holder))
      end if account_holder.present?
    end
    column :account_type, :sortable => :account_type do |account|
      account.account_type_label
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
      		end if admin.present?
	      end
        row(:initial_balance) { number_to_currency(criterion_account.balance, :unit => 'Rs. ', :precision => 0) }
      end
    end

    active_admin_comments
  end
end
