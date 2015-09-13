ActiveAdmin.register PhoneNumber do
	menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  index do
    column 'ID', sortable: :id do |number|
      link_to number.id, admin_phone_number_path(number)
    end
    column :contactable do |number|
      contactable = number.contactable
      if contactable.kind_of?(Student)
        link_to contactable.name, admin_student_path(contactable)
      elsif contactable.kind_of?(Teacher)
        link_to contactable.name, admin_teacher_path(contactable)
      elsif contactable.kind_of?(Partner)
        link_to contactable.name, admin_partner_path(contactable)
      elsif contactable.kind_of?(Staff)
        link_to contactable.name, admin_staff_path(contactable)
      end
    end
    column :contactable_type
    column :number
    column :category, sortable: :category do |number|
      number.category_label
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :number, required: true
      f.input :category, as: :select, collection: PhoneNumber.categories, include_blank: false, required: true
      f.input :contactable_id, as: :hidden
      f.input :contactable_type, as: :hidden
    end

    f.buttons
  end

  show title: :label do
    panel 'PhoneNumber Details' do
      attributes_table_for phone_number do
        row(:id) { phone_number.id }
        row(:contactable) do
          contactable = phone_number.contactable
          if contactable.kind_of?(Student)
            link_to contactable.name, admin_student_path(contactable)
          elsif contactable.kind_of?(Teacher)
            link_to contactable.name, admin_teacher_path(contactable)
          elsif contactable.kind_of?(Partner)
            link_to contactable.name, admin_partner_path(contactable)
          elsif contactable.kind_of?(Staff)
            link_to contactable.name, admin_staff_path(contactable)
          end
        end
        row(:contactable_type) { phone_number.contactable_type }
        row(:number) { phone_number.number }
        row(:category) { phone_number.category_label }
      end
    end

    panel 'Sent Messages' do
      table_for phone_number.sent_sms.each do |t|
        t.column(:id) { |sms| link_to(sms.id, admin_criterion_sm_path(sms)) }
        t.column(:sender) { |sms| sms.sender.email rescue nil }
        t.column(:message) { |sms| truncate sms.message }
        t.column(:status) { |sms| status_tag(sms.status_label, sms.status_tag) }
      end
    end

    active_admin_comments
  end

  controller do
    before_filter :check_authorization, except: [:new, :create]

    def check_authorization
      if !current_admin_user.super_admin_or_partner? && !current_admin_user.admin?
        phone_numbers = current_admin_user.user.phone_numbers.mobile.collect(&:id)

        action_allowed = false
        phone_numbers.each do |phone_number|
          if request.path == admin_phone_number_path(phone_number) || request.path == edit_admin_phone_number_path(phone_number)
            action_allowed = true 
            break
          end
        end

        unless action_allowed
          if current_admin_user.teacher?
            redirect_to admin_teacher_path(current_admin_user.user)
          else
            flash[:error] = 'You are not authorized to perform this action'
            redirect_to_back
          end
        end
      end
    end

    def create
      @phone_number = PhoneNumber.new(params[:phone_number])
      
      if @phone_number.save
        flash[:notice] = 'PhoneNumber Added'
        contactable = @phone_number.contactable
        if contactable.kind_of?(Student)
          redirect_to admin_student_path(contactable)
        elsif contactable.kind_of?(Teacher)
          redirect_to admin_teacher_path(contactable)
        elsif contactable.kind_of?(Partner)
          redirect_to admin_partner_path(contactable)
        elsif contactable.kind_of?(Staff)
          redirect_to admin_staff_path(contactable)
        end
      else
        render :new
      end
    end

    def update
      @phone_number = PhoneNumber.find(params[:id])
      @phone_number.attributes = params[:phone_number]
      
      if @phone_number.save
        flash[:notice] = 'PhoneNumber Updated'
        contactable = @phone_number.contactable
        if contactable.kind_of?(Student)
          redirect_to admin_student_path(contactable)
        elsif contactable.kind_of?(Teacher)
          redirect_to admin_teacher_path(contactable)
        elsif contactable.kind_of?(Partner)
          redirect_to admin_partner_path(contactable)
        elsif contactable.kind_of?(Staff)
          redirect_to admin_staff_path(contactable)
        end
      else
        render :new
      end
    end
  end
end