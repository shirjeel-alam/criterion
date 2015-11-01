ActiveAdmin.register ActionRequest do
  menu label: 'Action Requests', parent: 'Criterion', priority: 2, if: proc { current_admin_user.super_admin_or_partner? }

  actions :index

  scope :all
  scope :pending, default: true
  scope :approved
  scope :rejected

  index do
    column 'ID', sortable: :id do |action_request|
      action_request.id
    end
    column :action_item, sortable: :action_item_id do |action_request|
      action_item = action_request.action_item
      if action_item.is_a?(Enrollment)
        link_to(action_item.title, admin_enrollment_path(action_item))
      elsif action_item.is_a?(Payment)
        if action_item.payable.is_a?(Enrollment)
          link_to("#{action_item.payable.title} (Payment)", admin_payment_path(action_item))
        elsif action_item.payable.is_a?(SessionStudent)
          link_to("#{action_item.payable.session.title} (Registration Payment)", admin_payment_path(action_item))
        end
      else
        "Deleted #{action_request.action_item_type} - ID: #{action_request.action_item_id}"
      end 
    end
    column :action
    column :requested_by, sortable: :requested_by_id do |action_request|
      admin = action_request.requested_by
      case admin.role
      when AdminUser::TEACHER
        link_to(admin.user.name, admin_teacher_path(admin.user)) rescue admin.email
      when AdminUser::STUDENT
        link_to(admin.user.name, admin_student_path(admin.user)) rescue admin.email
      when AdminUser::PARTNER
        link_to(admin.user.name, admin_partner_path(admin.user)) rescue admin.email
      when AdminUser::ADMIN, AdminUser::STAFF
        link_to(admin.user.name, admin_staff_path(admin.user)) rescue admin.email
      end
    end
    column :state, sortable: :state do |action_request|
      status_tag(action_request.state_label, action_request.state_tag)
    end

    column nil do |action_request|
      if action_request.pending? && action_request.action_item.present?
        span link_to('Approve', approve_admin_action_request_path(action_request), method: :put, class: :member_link)
        span link_to('Reject', reject_admin_action_request_path(action_request), method: :put, class: :member_link)
      end
    end
  end

  member_action :approve, method: :put do
    action_request = ActionRequest.find(params[:id])
    action_request.approve_request!(current_admin_user)
    redirect_to action: :index
  end

  member_action :reject, method: :put do
    action_request = ActionRequest.find(params[:id])
    action_request.reject_request!(current_admin_user)
    redirect_to action: :index
  end
end