ActiveAdmin.register CriterionMail do
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
    active_admin_config.clear_action_items!

    def new
      if params[:course].present?
        session[:course] = params[:course]
        @course = Course.find(params[:course])
        @mail = Mail.new(:from => current_admin_user.email, :to => @course.emails)
      else
        super
      end
    end

    def create
      receipients = params[:mail][:to].reject!(&:blank?)
      params[:mail][:to] = params[:mail][:to].join(',').gsub(/ /,'')
      params[:mail][:cc] = params[:mail][:cc].gsub(/ /,'')
      params[:mail][:bcc] = params[:mail][:bcc].gsub(/ /,'')

      if current_admin_user.user.present?
        @mail = current_admin_user.user.mails.build(params[:mail])
      else
        @mail = current_admin_user.mails.build(params[:mail])
      end

      if @mail.save
        session.delete :course if session[:course].present?
        CriterionMailer.course_mail(@mail).deliver
        flash[:notice] = 'Mail sent successfully'
        redirect_to :back
      else
        @course = Course.find(session[:course]) if session[:course].present?
        @mail.to = @mail.to.split(',')
        render :new
      end
    end
  end
end
