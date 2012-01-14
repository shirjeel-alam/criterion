ActiveAdmin.register CriterionMail do
  menu :if => proc { current_admin_user.super_admin? }

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
        @criterion_mail = CriterionMail.new(:from => current_admin_user.email, :to => @course.emails)
      else
        super
      end
    end

    def create
      receipients = params[:criterion_mail][:to].reject!(&:blank?)
      params[:criterion_mail][:to] = params[:criterion_mail][:to].join(',').gsub(/ /,'')
      params[:criterion_mail][:cc] = params[:criterion_mail][:cc].gsub(/ /,'')
      params[:criterion_mail][:bcc] = params[:criterion_mail][:bcc].gsub(/ /,'')

      if current_admin_user.user.present?
        @criterion_mail = current_admin_user.user.criterion_mails.build(params[:criterion_mail])
      else
        @criterion_mail = current_admin_user.criterion_mails.build(params[:criterion_mail])
      end

      if @criterion_mail.save
        session.delete :course if session[:course].present?
        #CriterionMailer.course_mail(@criterion_mail).deliver
        flash[:notice] = 'Mail sent successfully'
        redirect_to :action => :show
      else
        @course = Course.find(session[:course]) if session[:course].present?
        @criterion_mail.to = @criterion_mail.to.split(',')
        render :new
      end
    end
  end
end
