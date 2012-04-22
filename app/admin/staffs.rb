ActiveAdmin.register Staff do
  menu :priority => 2, :if => proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

  filter :id
  filter :name
  filter :email

  index do
    column 'ID' do |staff|
      link_to(staff.id, admin_staff_path(staff))
    end
    column :name
    column :email
    column 'Contact Number' do |staff|
      if staff.phone_numbers.present?
        staff.phone_numbers.each { |number| div number.label } 
      else
        'No Phone Numbers Present'
      end
    end
    column 'Balance', :sortable => :balance do |staff|
      status_tag(number_to_currency(staff.balance, :unit => 'Rs. ', :precision => 0), staff.balance_tag) rescue nil
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name, :required => true
      f.input :email, :required => true
      f.input :admin_user_confirmation, :as => :radio, :label => 'Create system login?', :required => true

      f.has_many :phone_numbers do |fp|
        fp.input :number
        fp.input :category, :as => :select, :collection => PhoneNumber.categories, :include_blank => false, :input_html => { :class => 'chosen-select' }
      end
    end

    f.buttons
  end

  show :title => :name do
    panel 'Staff Details' do
      attributes_table_for staff do
        row(:id) { staff.id }
        row(:name) { staff.name }
        row(:email) { staff.email }
        row(:phone_numbers) do
          if staff.phone_numbers.present? 
            staff.phone_numbers.each do |number|
              div do
                span number.label
                # span link_to('View', admin_phone_number_path(number))
                span link_to('Edit', edit_admin_phone_number_path(number))
                span link_to('Delete', admin_phone_number_path(number), method: :delete, confirm: 'Are you sure?')
              end
            end
          else
            'No Phone Numbers Present'
          end
        end
        row(:balance) { status_tag(number_to_currency(staff.balance, :unit => 'Rs. ', :precision => 0), staff.balance_tag) rescue nil }
      end
    end

    panel 'Payments (Deposits)' do
      table_for staff.transactions.debit.each do |t|
        t.column(:id) { |deposit| link_to(deposit.id, admin_payment_path(deposit)) }
        t.column(:payment_date) { |deposit| date_format(deposit.payment_date) }
        t.column(:narration) { |deposit| truncate(deposit.additional_info, :length => 75) }
        t.column(:amount) { |deposit| number_to_currency(deposit.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |deposit| status_tag(deposit.status_label, deposit.status_tag) }
      end
    end if staff.transactions.debit.present?

    panel 'Payments (Withdrawal)' do
      table_for staff.transactions.credit.each do |t|
        t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
        t.column(:payment_date) { |withdrawal| date_format(withdrawal.payment_date) }
        t.column(:narration) { |withdrawal| truncate(withdrawal.additional_info, :length => 75) }
        t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
      end
    end if staff.transactions.credit.present?

    active_admin_comments
  end

  action_item :only => :show do
    span link_to('Add PhoneNumber', new_admin_phone_number_path(phone_number: { contactable_id: staff.id, contactable_type: staff.class.name }))
    span link_to('Debit Account (Withdrawal)', new_admin_payment_path(:staff_id => staff, :payment_type => Payment::CREDIT))
    span link_to('Credit Account (Deposit)', new_admin_payment_path(:staff_id => staff, :payment_type => Payment::DEBIT)) if current_admin_user.super_admin_or_partner?
  end

  controller do
    # active_admin_config.clear_action_items!

    before_filter :check_authorization
    
    def check_authorization
      unless current_admin_user.super_admin_or_partner? || current_admin_user.admin?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end
  end
end
