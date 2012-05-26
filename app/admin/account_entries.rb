ActiveAdmin.register AccountEntry do
  menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  show do
  	panel 'Account Entry Details' do
  		attributes_table_for account_entry do
  			row(:id) { |account_entry| link_to(account_entry.id, admin_account_entry_path(account_entry)) }
        row(:criterion_account) { |account_entry| link_to(account_entry.criterion_account.title, admin_criterion_account_path(account_entry.criterion_account)) }
        row(:payment) { |account_entry| link_to(account_entry.payment_id, admin_payment_path(account_entry.payment)) }
        row(:entry_type) { |account_entry| status_tag(account_entry.entry_type_label, account_entry.entry_type_tag) }
        row(:amount) { |account_entry| number_to_currency(account_entry.amount, unit: 'Rs. ', precision: 0) }
  		end
  	end

  	active_admin_comments
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.all_other?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end
  end
end
