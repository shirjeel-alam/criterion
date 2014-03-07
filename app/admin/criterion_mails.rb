ActiveAdmin.register CriterionMail do
  menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  filter :id
  filter :from
  filter :to
  filter :cc
  filter :bcc
  filter :subject
  filter :body
  filter :created_at, label: 'MAIL SENT BETWEEN'

  index do
    column 'ID', sortable: :id do |mail|
      link_to(mail.id, admin_criterion_mail_path(mail))
    end
    column :from
    column :to do |mail|
      truncate(mail.to)
    end
    column :subject
    column :sender do |mail|
      if mail.mailable.is_a?(Teacher)
        link_to(mail.mailable.name, admin_teacher_path(mail.mailable)) rescue nil
      else
        mail.mailable_type
      end
    end

    default_actions
  end

  form partial: 'form'

  show do
    criterion_mail.to = criterion_mail.to.split(',') rescue nil
    criterion_mail.cc = criterion_mail.cc.split(',') rescue nil
    criterion_mail.bcc = criterion_mail.bcc.split(',') rescue nil
    render partial: 'form', locals: { disabled: true }
  end

  controller do
    active_admin_config.clear_action_items!

    before_filter :check_authorization
    
    def check_authorization
      if current_admin_user.all_other?
        if %w[index show edit update destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end

    def new
      if params[:course].present?
        @course = Course.find(params[:course])
        @criterion_mail = CriterionMail.new(from: current_admin_user.email, to: @course.emails.collect(&:second))
      elsif params[:courses].present?
        @courses = Course.find(params[:courses].collect(&:second))
        @criterion_mail = CriterionMail.new(from: current_admin_user.email, to: @courses.collect { |course| course.emails.collect(&:second) }.flatten)
      elsif params[:teachers].present?
        @teachers = Teacher.find(params[:teachers].collect(&:second))
        @courses = @teachers.collect(&:courses).flatten
        @emails = (@teachers.collect(&:email) + @courses.collect { |course| course.emails.collect(&:second) }.flatten).flatten.uniq
        @criterion_mail = CriterionMail.new(from: current_admin_user.email, to: @emails)
      else
        @criterion_mail = CriterionMail.new(from: current_admin_user.email)
      end
    end

    def create
      params[:criterion_mail][:to] = params[:criterion_mail][:to].reject(&:blank?).join(',') if params[:criterion_mail][:to].present?
      params[:criterion_mail][:cc] = params[:criterion_mail][:cc].reject(&:blank?).join(',') if params[:criterion_mail][:cc].present?
      params[:criterion_mail][:bcc] = params[:criterion_mail][:bcc].reject(&:blank?).join(',') if params[:criterion_mail][:bcc].present?

      if current_admin_user.user.present?
        @criterion_mail = current_admin_user.user.criterion_mails.build(params[:criterion_mail])
      else
        @criterion_mail = current_admin_user.criterion_mails.build(params[:criterion_mail])
      end

      if @criterion_mail.save
        CriterionMailer.course_mail(@criterion_mail).deliver
        flash[:notice] = 'Mail sent successfully'
        redirect_to admin_criterion_mailer_path
      else
        @criterion_mail.to = @criterion_mail.to.split(',') unless @criterion_mail.to.blank?
        @criterion_mail.cc = @criterion_mail.cc.split(',') unless @criterion_mail.cc.blank?
        @criterion_mail.bcc = @criterion_mail.bcc.split(',') unless @criterion_mail.bcc.blank?
        render :new
      end
    end
  end
end
