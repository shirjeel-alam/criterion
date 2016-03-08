ActiveAdmin.register CriterionAccount do
  menu parent: 'Criterion', priority: 2, if: proc { current_admin_user.super_admin_or_partner? }

  actions :index, :show, :edit, :update

  index do
    column 'ID', sortable: :id do |account|
      link_to(account.id, admin_criterion_account_path(account))
    end
    column 'Account Holder', sortable: :admin_user_id do |account|
      account_holder = account.admin_user
      case account_holder.role
      when AdminUser::TEACHER
        link_to(account_holder.user.name, admin_teacher_path(account_holder.user)) rescue nil
      when AdminUser::STAFF
        link_to(account_holder.user.name, admin_staff_path(account_holder.user)) rescue nil
      when AdminUser::STUDENT
        link_to(account_holder.user.name, admin_student_path(account_holder.user)) rescue nil
      when AdminUser::PARTNER
        link_to(account_holder.user.name, admin_partner_path(account_holder.user)) rescue nil
      when AdminUser::ADMIN, AdminUser::STAFF
        link_to(account_holder.user.name, admin_staff_path(account_holder.user)) rescue nil
      else
        link_to(account_holder.email, admin_admin_user_path(account_holder)) rescue nil
      end if account_holder.present?
    end
    column :account_type, sortable: :account_type do |account|
      account.account_type_label
    end
    column 'Balance' do |account|
      status_tag(number_to_currency(account.balance, unit: 'Rs. ', precision: 0), account.balance_tag)
    end

    default_actions
  end

  show title: :title do
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
        row(:current_balance) { status_tag(number_to_currency(criterion_account.balance, unit: 'Rs. ', precision: 0), criterion_account.balance_tag) }
      end
    end

    panel 'Account Entries' do
      paginated_collection(criterion_account.account_entries.page(params[:page]).per(25)) do
        table_for collection do |t|
          t.column(:id) { |account_entry| link_to(account_entry.id, admin_account_entry_path(account_entry)) }
          t.column(:date) { |account_entry| date_format(account_entry.created_at) }
          t.column(:particular) { |account_entry| criterion_account.criterion_account? ? account_entry.payment.particular_extended : account_entry.payment.particular }
          t.column(:payment) { |account_entry| link_to(account_entry.payment_id, admin_payment_path(account_entry.payment)) }
          t.column(:debit) { |account_entry| number_to_currency(account_entry.amount, unit: 'Rs. ', precision: 0) if account_entry.debit? }
          t.column(:credit) { |account_entry| number_to_currency(account_entry.amount, unit: 'Rs. ', precision: 0) if account_entry.credit? }
          t.column(:balance) do |account_entry|
            number_to_currency(criterion_account.running_balance(account_entry.id), unit: 'Rs. ', precision: 0)
          end
        end
      end
    end if criterion_account.account_entries.present?

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :initial_balance
    end

    f.buttons
  end

  action_item only: :show do
    span link_to('Debit Account (Deposit)', new_admin_payment_path(payment: { status: Payment::PAID, payment_date: Time.current.to_date, payment_type: Payment::DEBIT, category_id: Category.direct_deposit.id })) if criterion_account.bank_account?
    span link_to('Appropriate To Partner(s)', new_admin_payment_path(payment: { payment_type: Payment::CREDIT, category_id: Category.appropriated.id, status: Payment::PAID, payment_date: Time.current.to_date, payment_method: Payment::INTERNAL })) if criterion_account.criterion_account?
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.all_other?
        unless request.path == admin_criterion_account_path(current_admin_user.criterion_account)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end
  end
end
