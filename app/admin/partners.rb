ActiveAdmin.register Partner do
 	menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }
  
  filter :id
  filter :name
  filter :email
  filter :share
  
  index do
    column 'ID' do |partner|
      link_to(partner.id, admin_partner_path(partner))
    end
    column :name
    column :email
    column :share, :sortable => :share do |partner|
      number_to_percentage(partner.share * 100, :precision => 0)
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name, :required => true
      f.input :email, :required => true
      f.input :share, :required => true, :step => 0.05

      f.has_many :phone_numbers do |fp|
        fp.input :number
        fp.input :category, :as => :select, :collection => PhoneNumber.categories, :include_blank => false, :input_html => { :class => 'chosen-select' }
      end
    end

    f.buttons
  end
  
  show :title => :name do
    panel 'Staff Details' do
      attributes_table_for partner do
        row(:id) { partner.id }
        row(:name) { partner.name }
        row(:email) { partner.email }
        row(:share) { number_to_percentage(partner.share * 100, :precision => 0) }
      end
    end

    panel 'Payments (Deposits)' do
      table_for partner.transactions.debit.each do |t|
        t.column(:id) { |deposit| link_to(deposit.id, admin_payment_path(deposit)) }
        t.column(:amount) { |deposit| number_to_currency(deposit.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |deposit| status_tag(deposit.status_label, deposit.status_tag) }
        t.column(:payment_date) { |deposit| date_format(deposit.payment_date) }
      end
    end if partner.transactions.debit.present?

    panel 'Payments (Withdrawal)' do
      table_for partner.transactions.credit.each do |t|
        t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
        t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
        t.column(:payment_date) { |withdrawal| date_format(withdrawal.payment_date) }
      end
    end if partner.transactions.credit.present?

    active_admin_comments
  end 

  action_item :only => :show do
    span link_to('Debit Account (Withdrawal)', new_admin_payment_path(:partner_id => partner, :payment_type => Payment::CREDIT))
    span link_to('Credit Account (Deposit)', new_admin_payment_path(:partner_id => partner, :payment_type => Payment::DEBIT)) if current_admin_user.super_admin?
  end

  controller do
    before_filter :check_authorization
    
    def check_authorization
      unless current_admin_user.super_admin?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end
  end
end
