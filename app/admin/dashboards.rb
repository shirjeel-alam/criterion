ActiveAdmin::Dashboards.build do

  section :disable_dasboard, if: proc { current_admin_user.teacher? } do
    controller.redirect_to admin_teacher_path(current_admin_user.user)
  end

  section 'Criterion Dashboard', if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? } do
    div style: 'float:left' do
      ul style: 'list-style:none' do
        li class: 'dashboard_btn' do 
          link_to 'Add Student', new_admin_student_path, class: 'btn'
        end
        li class: 'dashboard_btn' do 
          link_to 'Find Student', '#find_student', class: 'btn fancybox'
        end
        li class: 'dashboard_btn' do 
          link_to 'Add Course', new_admin_course_path, class: 'btn'
        end
        li class: 'dashboard_btn' do 
          link_to 'Find Course', '#find_course', class: 'btn fancybox'
        end
        li class: 'dashboard_btn' do
          link_to 'Add Teacher', new_admin_teacher_path, class: 'btn'
        end if current_admin_user.super_admin_or_partner?
        li class: 'dashboard_btn' do 
          link_to 'Find Teacher', '#find_teacher', class: 'btn fancybox'
        end
        li class: 'dashboard_btn' do 
          link_to 'Add Expenditure', new_admin_payment_path(payment: { status: Payment::PAID, payment_date: Date.today, payment_type: Payment::CREDIT }), class: 'btn'
        end
      end
    end

    div style: 'display:inline-block;width:87%' do
      due_payments = Payment.due_fees(Date.today).collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = due_payments.group_by { |payment| payment.payable.course }.sort_by { |course_payments| course_payments.first.name }

      due_registration_fees = Payment.due_registration_fees

      table do
        status_tag 'Due Payments', :red, style: 'font-size:2em;font-weight:bold;display:block;text-align:center;'
        thead do
          tr do
            th 'ID'
            th 'Course'
            th 'Student'
            th 'Period'
            th 'Net Amount'
          end
        end

        tbody do
          flip = true

          tr class: 'even header' do
            td image_tag('down_arrow.png')
            td do
              strong 'Registration Fee'
            end
            td due_registration_fees.count
            td nil
            td number_to_currency(due_registration_fees.collect(&:net_amount).sum, unit: 'Rs. ', precision: 0)
          end

          due_registration_fees.each do |payment|
            tr class: 'odd content' do
              td link_to(payment.id, admin_payment_path(payment))
              td nil
              td link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue td nil
              td payment.payable.session.label
              td number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0)
            end
          end

          result.each do |course_due_payments|
            tr class: "#{flip ? 'odd' : 'even'} header" do
              td image_tag('down_arrow.png')
              td link_to(course_due_payments.first.name, admin_course_path(course_due_payments.first)) rescue td nil
              td course_due_payments.second.count
              td nil
              td number_to_currency(course_due_payments.second.collect(&:net_amount).sum, unit: 'Rs. ', precision: 0)
            end

            flip = !flip
            course_due_payments.second.sort_by(&:id).each do |payment|
              tr class: "#{flip ? 'odd' : 'even'} content" do
                td link_to(payment.id, admin_payment_path(payment))
                if payment.payable.is_a?(Enrollment) || payment.payable.is_a?(SessionStudent)
                  td link_to(payment.payable.course.name, admin_course_path(payment.payable.course)) rescue td nil
                  td link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue td nil
                else
                  td nil
                  td nil
                end
                td payment.period_label
                td number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0)
              end
            end
          end
        end
      end
    end

    div style: 'clear:both'

    # Find A Student
    div style: 'display:none' do
      div id: 'find_student' do
        render 'find_student'
      end
    end

    # Find A Course
    div style: 'display:none' do
      div id: 'find_course' do
        render 'find_course'
      end
    end

    # Find A Teacher
    div style: 'display:none' do
      div id: 'find_teacher' do
        render 'find_teacher'
      end
    end
  end

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
