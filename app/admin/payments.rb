ActiveAdmin.register Payment do
  menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  filter :id
  filter :amount

  scope :all
  scope :paid
  scope :due
  scope :void
  scope :credit
  scope :debit
  scope :cash
  scope :cheque

  index do
    column 'ID', sortable: :id do |payment|
      link_to(payment.id, admin_payment_path(payment))
    end
    column :period, sortable: :period do |payment|
      payment.period_label
    end
    column :amount, sortable: :amount do |payment|
      number_to_currency(payment.amount, unit: 'Rs. ', precision: 0)
    end
    column :discount, sortable: :discount do |payment|
      number_to_currency(payment.discount, unit: 'Rs. ', precision: 0)
    end
    column :status, sortable: :status do |payment|
      status_tag(payment.status_label, payment.status_tag)
    end
    column :payment_type, sortable: :payment_type do |payment|
      status_tag(payment.type_label, payment.type_tag)
    end
    column :payment_date, sortable: :payment_date do |payment|
      date_format(payment.payment_date)
    end
    column :payment_method, sortable: :payment_method do |payment|
      status_tag(payment.payment_method_label, payment.payment_method_tag)
    end
    column :payable do |payment|
      if payment.payable.is_a?(Enrollment) || payment.payable.is_a?(SessionStudent)
        link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
      elsif payment.payable.is_a?(Teacher)
        link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
      elsif payment.payable.is_a?(Partner)
        link_to(payment.payable.name, admin_partner_path(payment.payable)) rescue nil
      end
    end
    column :category, sortable: :category_id do |payment|
      payment.category.name_label rescue nil
    end
  end

  form partial: 'payment_form'

  show do
    panel 'Payment Details' do
      attributes_table_for payment do
        row(:id) { payment.id }
        row(:payable) do
          if payment.payable.is_a?(Enrollment) || payment.payable.is_a?(SessionStudent)
            link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
          elsif payment.payable.is_a?(Teacher)
            link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
          elsif payment.payable.is_a?(Partner)
            link_to(payment.payable.name, admin_partner_path(payment.payable)) rescue nil
          end
        end
        row(:payable_type) { payment.payable_type }
        row(:period) { payment.period_label }
        row(:amount) { number_to_currency(payment.amount, unit: 'Rs. ', precision: 0) }
        row(:discount) { number_to_currency(payment.discount, unit: 'Rs. ', precision: 0) }
        row(:net_amount) { number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0) }
        row(:status) { status_tag(payment.status_label, payment.status_tag) }
        row(:payment_type) { status_tag(payment.type_label, payment.type_tag) }
        row(:payment_method) { status_tag(payment.payment_method_label, payment.payment_method_tag) }
        row(:payment_date) { date_format(payment.payment_date) }
        row(:category) { payment.category.name_label rescue nil }
        row(:additional_info) { payment.additional_info }
      end
    end

    panel 'Account Entries' do
      table_for payment.account_entries do |t|
        t.column(:id) { |account_entry| link_to(account_entry.id, admin_account_entry_path(account_entry)) }
        t.column(:criterion_account) { |account_entry| link_to(account_entry.criterion_account.title, admin_criterion_account_path(account_entry.criterion_account)) }
        t.column(:entry_type) { |account_entry| status_tag(account_entry.entry_type_label, account_entry.entry_type_tag) }
        t.column(:amount) { |account_entry| number_to_currency(account_entry.amount, unit: 'Rs. ', precision: 0) }
      end
    end if payment.account_entries.present?

    active_admin_comments
  end
  
  member_action :pay, method: :get do
    @payment = Payment.find(params[:id])
    @payment.attributes = { status: Payment::PAID, payment_date: Time.current.to_date }
  end

  member_action :paid, method: :put do
    @payment = Payment.find(params[:id])
    @payment.attributes = params[:payment]

    if @payment.save
      @payment.create_account_entry
      @payment.send_fee_received_sms
      flash[:notice] = 'Payment successfully paid.'
      if @payment.payable.is_a?(SessionStudent) || @payment.payable.is_a?(Enrollment)
        redirect_to admin_student_path(@payment.payable.student)
      else
        redirect_to send("admin_#{@payment.payable_type.downcase}_path", @payment.payable)
      end
    else
      flash[:notice] = 'Error in processing payment.'
      if @payment.payable.is_a?(SessionStudent) || @payment.payable.is_a?(Enrollment)
        redirect_to admin_student_path(@payment.payable.student)
      else
        redirect_to send("admin_#{@payment.payable_type.downcase}_path", @payment.payable)
      end
    end
  end

  member_action :void, method: :put do
    if current_admin_user.super_admin_or_partner?
      payment = Payment.find(params[:id])
      payment.void! ? flash[:notice] = 'Payment successfully voided.' : flash[:notice] = 'Error in processing payment.'
      redirect_to_back
    else
      payment = Payment.find(params[:id])
      action_request = ActionRequest.where(action: 'void', action_item_id: payment.id, action_item_type: payment.class.name).first_or_initialize
      action_request.requested_by = current_admin_user
      action_request.save

      flash[:warning] = 'Request has been sent for approval'
      redirect_to_back
    end
  end
  
  member_action :refund, method: :put do
    payment = Payment.find(params[:id])
    payment.refund! ? flash[:notice] = 'Payment successfully refunded.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end

  collection_action :pay_cumulative, method: :get do
  	@payments = Payment.find(params[:payments])
    session[:payment_ids] = @payments.collect(&:id)
  end

  collection_action :paid_cumulative, method: :post do
    @payments = Payment.find(session[:payment_ids])
    @student = @payments.first.payable.student

    successful_payment_ids = []
    count = 0
    @payments.each do |payment|
      if payment.due?
        payment.attributes = params[:payment]
        if payment.save
          payment.create_account_entry
          successful_payment_ids << payment.id
          count += 1
        end
      end
    end

    CriterionSms.delay.send_cumulative_fee_received_sms(successful_payment_ids)

    flash[:notice] = "#{count} of #{@payments.count} payment(s) successfully made."
    redirect_to admin_student_path(@student)
  end

  controller do
    before_filter :check_authorization, except: [:new, :create, :show]

    def check_authorization
      if current_admin_user.admin?
        if %w[index destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      elsif current_admin_user.all_other?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def new
      if params[:teacher_id]
        @account_holder = Teacher.find(params[:teacher_id])
        @payment = @account_holder.transactions.build(payment_type: params[:payment_type], status: Payment::PAID, payment_date: Time.current.to_date)
        session[:holder_type] = 'Teacher'
      elsif params[:staff_id]
        @account_holder = Staff.find(params[:staff_id])
        @payment = @account_holder.transactions.build(payment_type: params[:payment_type], status: Payment::PAID, payment_date: Time.current.to_date)
        session[:holder_type] = 'Staff'
      elsif params[:partner_id]
        @account_holder = Partner.find(params[:partner_id])
        @payment = @account_holder.transactions.build(payment_type: params[:payment_type], status: Payment::PAID, payment_date: Time.current.to_date)
        session[:holder_type] = 'Partner'
      elsif params[:category_id]
        @payment = Payment.new(payment_type: params[:payment_type],  category_id: params[:category_id], status: Payment::PAID, payment_date: Time.current.to_date)
      else
        @payment = Payment.new(params[:payment])
      end

      session[:holder_id] = params[:teacher_id] || params[:staff_id] || params[:partner_id] || params[:category_id]
      session[:limited] = true if params[:teacher_id] || params[:staff_id] || params[:partner_id] || params[:category_id]
    end

    def create
      @payment = Payment.new(params[:payment])

      amount_exceeded = false
      amount_exceeded = (@payment.amount > @payment.payable.balance rescue false) if current_admin_user.admin?
      
      if !amount_exceeded && @payment.save
        session.delete :holder_id
        session.delete :holder_type
        session.delete :limited

        if @payment.payable.present?
          flash[:notice] = @payment.credit? ? 'Account debited successfully' : 'Account credited successfully'
          redirect_to send("admin_#{@payment.payable_type.downcase}_path", @payment.payable)
        elsif @payment.appropriated?
          flash[:notice] = 'Amount successfully appropriated'
          redirect_to admin_criterion_account_path(CriterionAccount.criterion_account)
        else
          if @payment.credit?
            flash[:notice] = 'Expenditure successfully created'
            redirect_to admin_expenditures_path
          elsif @payment.debit?
            flash[:notice] = 'Account successfully debited'
            redirect_to admin_criterion_account_path(CriterionAccount.bank_account)
          end
        end
      else
        flash[:error] = 'Amount entered exceeds account holder balance' if amount_exceeded

        if session[:holder_type] == 'Teacher'
          @account_holder = Teacher.find(session[:holder_id])
        elsif session[:holder_type] == 'Staff'
          @account_holder = Staff.find(session[:holder_id])
        elsif session[:holder_type] == 'Partner'
          @account_holder = Partner.find(session[:holder_id])
        end
        
        render :new
      end
    end
  end
end
