ActiveAdmin.register Partner do
 	menu priority: 2, if: proc { current_admin_user.super_admin_or_partner? }
  
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
    column :share, sortable: :share do |partner|
      number_to_percentage(partner.share * 100, precision: 0)
    end
    column 'Contact Number' do |partner|
      if partner.phone_numbers.present?
        partner.phone_numbers.each { |number| div number.label } 
      else
        'No Phone Numbers Present'
      end
    end
    column 'Balance' do |partner|
      status_tag(number_to_currency(partner.balance, unit: 'Rs. ', precision: 0), partner.balance_tag) rescue nil
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name, required: true
      f.input :email, required: true
      f.input :share, required: true, step: 0.05

      f.has_many :phone_numbers do |fp|
        fp.input :number
        fp.input :category, as: :select, collection: PhoneNumber.categories, include_blank: false, input_html: { class: 'chosen-select' }
      end
    end

    f.buttons
  end
  
  show title: :name do
    panel 'Partner Details' do
      attributes_table_for partner do
        row(:id) { partner.id }
        row(:name) { partner.name }
        row(:email) { partner.email }
        row(:share) { number_to_percentage(partner.share * 100, precision: 0) }
        row(:phone_numbers) do
          if partner.phone_numbers.present? 
            partner.phone_numbers.each do |number|
              div do
                span number.label
                # span link_to('View', admin_phone_number_path(number))
                span link_to('Edit', edit_admin_phone_number_path(number))
                span link_to('Delete', admin_phone_number_path(number), method: :delete, data: { confirm: 'Are you sure?' })
              end
            end
          else
            'No Phone Numbers Present'
          end
        end
        row(:balance) { status_tag(number_to_currency(partner.balance, unit: 'Rs. ', precision: 0), partner.balance_tag) rescue nil }
      end
    end

    panel 'Payments (Deposits)' do
      table_for partner.transactions.debit.order('payment_date').each do |t|
        t.column(:id) { |deposit| link_to(deposit.id, admin_payment_path(deposit)) }
        t.column(:payment_date) { |deposit| date_format(deposit.payment_date) }
        t.column(:narration) { |deposit| truncate(deposit.additional_info, length: 75) }
        t.column(:amount) { |deposit| number_to_currency(deposit.amount, unit: 'Rs. ', precision: 0) }
        t.column(:status) { |deposit| status_tag(deposit.status_label, deposit.status_tag) }
      end
    end if partner.transactions.debit.present?

    panel 'Payments (Withdrawal)' do
      table_for partner.transactions.credit.order('payment_date').each do |t|
        t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
        t.column(:payment_date) { |withdrawal| date_format(withdrawal.payment_date) }
        t.column(:narration) { |withdrawal| truncate(withdrawal.additional_info, length: 75) }
        t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, unit: 'Rs. ', precision: 0) }
        t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
      end
    end if partner.transactions.credit.present?

    active_admin_comments
  end

  action_item only: :show do
    span link_to('Add PhoneNumber', new_admin_phone_number_path(phone_number: { contactable_id: partner.id, contactable_type: partner.class.name }))
    span link_to('Debit Account (Withdrawal)', new_admin_payment_path(partner_id: partner, payment_type: Payment::CREDIT))
    span link_to('Credit Account (Deposit)', new_admin_payment_path(partner_id: partner, payment_type: Payment::DEBIT)) if current_admin_user.super_admin_or_partner?
  end

  controller do
    before_filter :check_authorization
    
    def check_authorization
      unless current_admin_user.super_admin_or_partner?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end
  end
end
