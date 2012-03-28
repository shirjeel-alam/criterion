ActiveAdmin.register Teacher do
  menu :priority => 2, :if => proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }
  
  filter :id
  filter :name
  filter :email
  filter :share

  index do
    column 'ID' do |teacher|
      link_to(teacher.id, admin_teacher_path(teacher))
    end
    column :name
    column :email
    column :share, :sortable => :share do |teacher|
      number_to_percentage(teacher.share * 100, :precision => 0)
    end if current_admin_user.super_admin_or_partner?
    column 'Balance', :sortable => :balance do |teacher|
      status_tag(number_to_currency(teacher.balance, :unit => 'Rs. ', :precision => 0), teacher.balance_tag) rescue nil
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
    panel 'Teacher Details' do
      attributes_table_for teacher do
        row(:id) { teacher.id }
        row(:name) { teacher.name }
        row(:email) { teacher.email }
        row(:share) { number_to_percentage(teacher.share * 100, :precision => 0) } if current_admin_user.super_admin_or_partner?
        row(:balance) { status_tag(number_to_currency(teacher.balance, :unit => 'Rs. ', :precision => 0), teacher.balance_tag) rescue nil }
      end
    end

    panel 'Payments (Income)' do
      temp_payments = teacher.payments.debit.collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = temp_payments.group_by(&:period)
      
      table do
        thead do
          tr do
            th 'ID'
            th 'Period'
            th 'Student'
            th 'Course'
            th 'Gross Amount'
            th 'Status'
            th 'Net Amount'
          end
        end
        
        tbody do
          flip = true
          result.each do |cumulative_payment|
            tr :class => "#{flip ? 'odd' : 'even'} header" do
              cumulative_amount = cumulative_payment.second.sum(&:net_amount)

              td image_tag('down_arrow.png')
              td cumulative_payment.first.strftime('%B %Y')
              td nil
              td nil
              td '-'
              td status_tag(cumulative_amount > 0 ? 'Due' : 'Paid', cumulative_amount > 0 ? :error : :ok)
              td status_tag(number_to_currency(cumulative_amount * teacher.share, :unit => 'Rs. ', :precision => 0), :warning)
            end
            
            flip = !flip
            cumulative_payment.second.each do |payment|
              tr :class => "#{flip ? 'odd' : 'even'} content" do
                td link_to(payment.id, admin_payment_path(payment))
                td payment.period_label
                td link_to(payment.payable.student.name, admin_course_path(payment.payable.student))
                td link_to(payment.payable.course.name, admin_course_path(payment.payable.course))
                td number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0)
                td status_tag(payment.status_label, payment.status_tag)
                td number_to_currency(payment.net_amount * teacher.share, :unit => 'Rs. ', :precision => 0)
              end
            end
          end
        end
      end
    end if teacher.payments.debit.present?

    panel 'Payments (Deposits)' do
      table_for teacher.transactions.debit.each do |t|
        t.column(:id) { |deposit| link_to(deposit.id, admin_payment_path(deposit)) }
        t.column(:payment_date) { |deposit| date_format(deposit.payment_date) }
        t.column(:narration) { |deposit| truncate(deposit.additional_info, :length => 75) }
        t.column(:amount) { |deposit| number_to_currency(deposit.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |deposit| status_tag(deposit.status_label, deposit.status_tag) }
      end
    end if teacher.transactions.debit.present?

    panel 'Payments (Withdrawal)' do
      table_for teacher.transactions.credit.each do |t|
        t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
        t.column(:payment_date) { |withdrawal| date_format(withdrawal.payment_date) }
        t.column(:narration) { |withdrawal| truncate(withdrawal.additional_info, :length => 75) }
        t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
      end
    end if teacher.transactions.credit.present?

    active_admin_comments
  end

  action_item :only => :show do
    span link_to('Debit Account (Withdrawal)', new_admin_payment_path(:teacher_id => teacher, :payment_type => Payment::CREDIT))
    span link_to('Credit Account (Deposit)', new_admin_payment_path(:teacher_id => teacher, :payment_type => Payment::DEBIT)) if current_admin_user.super_admin_or_partner?
  end

  controller do
    before_filter :check_authorization
    
    def check_authorization
      if current_admin_user.admin?
        if %w[edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end
  end
end