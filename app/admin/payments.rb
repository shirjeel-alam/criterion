ActiveAdmin.register Payment do
  menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin_or_partner? }

  filter :id
  filter :amount
  filter :status, :as => :select, :collection => lambda { Payment.statuses }
  filter :payment_type, :as => :select, :collection => lambda { Payment.payment_types }
  filter :payment_method, :as => :select, :collection => lambda { Payment.payment_methods }
  filter :category, :as => :select, :collection => lambda { Category.categories }

  scope :all
  scope :paid
  scope :due
  scope :void
  scope :credit
  scope :debit
  scope :cash
  scope :cheque

  index do
    column 'ID', :sortable => :id do |payment|
      link_to(payment.id, admin_payment_path(payment))
    end
    column :period, :sortable => :period do |payment|
      payment.period_label
    end
    column :amount, :sortable => :amount do |payment|
      number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0)
    end
    column :discount, :sortable => :discount do |payment|
      number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0)
    end
    column :status, :sortable => :status do |payment|
      status_tag(payment.status_label, payment.status_tag)
    end
    column :payment_type, :sortable => :payment_type do |payment|
      status_tag(payment.type_label, payment.type_tag)
    end
    column :payment_date, :sortable => :payment_date do |payment|
      date_format(payment.payment_date)
    end
    column :payment_method, :sortable => :payment_method do |payment|
      status_tag(payment.payment_method_label, payment.payment_method_tag)
    end
    column :payable do |payment|
      if payment.payable.is_a?(Enrollment)
        link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
      elsif payment.payable.is_a?(Teacher)
        link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
      end
    end
    column :category, :sortable => :category_id do |payment|
      payment.category.name_label rescue nil
    end

    # default_actions
  end

  form :partial => 'form'

  show do
    panel 'Payment Details' do
      attributes_table_for payment do
        row(:id) { payment.id }
        row(:payable) { payment.payable }
        row(:payable_type) { payment.payable_type }
        row(:period) { payment.period_label }
        row(:amount) { number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        row(:discount) { number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
        row(:status) { status_tag(payment.status_label, payment.status_tag) }
        row(:payment_type) { status_tag(payment.type_label, payment.type_tag) }
        row(:payment_date) { date_format(payment.payment_date) }
        row(:category) { payment.category.name_label rescue nil }
      end
    end

    panel 'Account Entries' do
      table_for payment.account_entries do |t|
        t.column(:id) { |account_entry| link_to(account_entry.id, admin_account_entry_path(account_entry)) }
        t.column(:criterion_account) { |account_entry| link_to(account_entry.criterion_account.title, admin_criterion_account_path(account_entry.criterion_account)) }
        #t.column(:payment) { |account_entry| link_to(account_entry.payment_id, admin_payment_path(account_entry.payment)) }
        t.column(:entry_type) { |account_entry| status_tag(account_entry.entry_type_label, account_entry.entry_type_tag) }
        t.column(:amount) { |account_entry| number_to_currency(account_entry.amount, :unit => 'Rs. ', :precision => 0) }
      end
    end

    active_admin_comments
  end
  
  member_action :pay, :method => :put do
    payment = Payment.find(params[:id])
    payment.pay! ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end

  member_action :void, :method => :put do
    payment = Payment.find(params[:id])
    payment.void! ? flash[:notice] = 'Payment successfully voided.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end
  
  member_action :refund, :method => :put do
    payment = Payment.find(params[:id])
    payment.refund! ? flash[:notice] = 'Payment successfully refunded.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end

  collection_action :pay_cumulative, :method => :put do
  	payments = Payment.find(params[:payments])
  	count = 0
  	payments.each do |payment|
  		if payment.due?
  			payment.pay!
  			count += 1
  		end
  	end
  	flash[:notice] = "#{count} payment(s) successfully made."
  	redirect_to_back
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      unless current_admin_user.super_admin_or_partner?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def new
      if params[:teacher_id]
        @teacher = Teacher.find(params[:teacher_id])
        @payment = @teacher.transactions.build(:payment_type => params[:payment_type], :status => Payment::PAID, :payment_date => Date.today)
      elsif params[:staff_id]
        @staff = Staff.find(params[:staff_id])
        @payment = @staff.transactions.build(:payment_type => params[:payment_type], :status => Payment::PAID, :payment_date => Date.today)
      elsif params[:partner_id]
        @partner = Partner.find(params[:partner_id])
        @payment = @partner.transactions.build(:payment_type => params[:payment_type], :status => Payment::PAID, :payment_date => Date.today)
      elsif params[:category_id]
        @payment = Payment.new(:payment_type => params[:payment_type],  :category_id => params[:category_id],:status => Payment::PAID, :payment_date => Date.today)
      else
        @payment = Payment.new(params[:payment])
      end
    end

    def create
      @payment = Payment.new(params[:payment])
      
      if @payment.save
        if @payment.payable.present?
          flash[:notice] = @payment.credit? ? 'Account debited successfully' : 'Account credited successfully'
          redirect_to send("admin_#{@payment.payable_type.downcase}_path", @payment.payable)
        elsif @payment.appropriated?
          flash[:notice] = 'Amount successfully appropriated'
          redirect_to admin_criterion_account_path(CriterionAccount.criterion_account)
        else
          flash[:notice] = 'Expenditure successfully created'
          redirect_to admin_expenditures_path
        end
      else
        render :new
      end
    end
  end
end
