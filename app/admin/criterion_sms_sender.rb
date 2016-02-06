ActiveAdmin.register_page "Criterion SMS Sender" do
  menu label: 'Send SMS', parent: 'Criterion', priority: 2, if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

  sidebar :filter do
    render 'filter'
  end

  content do
    render 'criterion_sms_sender'
  end

  controller do
    def index
      params[:search].each do |filter_attrib|
        params[:search].delete(filter_attrib.first) if filter_attrib.last.reject(&:blank?).blank?
      end if params[:search].present?

      @due_fees = params[:due_fees].present?
      @include_cancelled = params[:include_cancelled].present?
      @search = Course.search(params[:search])
      @courses = @due_fees ? @search.relation.with_due_fees(Time.current.to_date).uniq : @search.relation
    end
  end
end