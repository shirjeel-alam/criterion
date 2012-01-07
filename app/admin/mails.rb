ActiveAdmin.register Mail do
  filter :id
  filter :from
  filter :to
  filter :cc
  filter :bcc
  filter :subject
  filter :body
  filter :created_at, :label => 'MAIL SENT BETWEEN'

  form :partial => 'form'

  controller do
    def new
      @course = Course.find(params[:course])
      @mail = Mail.new(:from => current_admin_user.email, :to => @course.emails)
    end

    def create
      debugger
      @mail = Mail.new(params[:mail])
      redirect_to admin_mails_path
    end
  end
end
