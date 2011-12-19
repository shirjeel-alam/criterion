ActiveAdmin.register Teacher do
  filter :id
  filter :name
  filter :share
  
  index do
    column 'ID' do |teacher|
      link_to(teacher.id, admin_teacher_path(teacher))
    end
    column :name
    column 'Share', :sortable => :share do |teacher|
      number_to_percentage(teacher.share * 100, :precision => 0)
    end

    default_actions
  end

  show :title => :name do
    panel 'Teacher Details' do
      attributes_table_for teacher do
        row(:id) { teacher.id }
        row(:name) { teacher.name }
        row(:share) { number_to_percentage(teacher.share * 100, :precision => 0) }
        row(:balance) { number_to_currency(teacher.balance, :unit => 'Rs. ', :precision => 0) }
      end
    end

    panel 'Payments (Income)' do
      temp_payments = teacher.payments.credit.collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = temp_payments.group_by(&:period)
      
      table do
        thead do
          tr do
            th 'ID'
            th 'Period'
            th 'Student'
            th 'Course'
            th 'Gross Amount'
            th 'Net Amount'
            #th 'Status'
          end
        end
        
        tbody do
          flip = true
          result.each do |cumulative_payment|
            tr :class => "#{flip ? 'odd' : 'even'} header" do
              #cumulative_amount = cumulative_payment.second.sum { |p| p.status ? 0 : p.amount } * teacher.share
              cumulative_amount = cumulative_payment.second.sum(&:amount)

              td image_tag('down_arrow.png')
              td cumulative_payment.first.strftime('%B %Y')
              td nil
              td nil
              td status_tag(number_to_currency(cumulative_amount, :unit => 'Rs. ', :precision => 0), :ok)
              td status_tag(number_to_currency(cumulative_amount  * teacher.share, :unit => 'Rs. ', :precision => 0), :warning)
              #td status_tag(cumulative_amount > 0 ? 'Due' : 'Paid', cumulative_amount > 0 ? :error : :ok)
              #td link_to('Make Payment (Cumulative)', pay_cumulative_admin_payments_path(:payments => cumulative_payment.second), :method => :put)
            end
            
            flip = !flip
            cumulative_payment.second.each do |payment|
              tr :class => "#{flip ? 'odd' : 'even'} content" do
                td link_to(payment.id, admin_payment_path(payment))
                td payment.period_label
                td link_to(payment.payable.student.name, admin_course_path(payment.payable.student))
                td link_to(payment.payable.course.name, admin_course_path(payment.payable.course))
                td number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0)
                td number_to_currency(payment.amount * teacher.share, :unit => 'Rs. ', :precision => 0)
                #td status_tag(payment.status_label, payment.status_tag)
                #td link_to('Make Payment', pay_admin_payment_path(payment), :method => :put)
              end
            end
          end
        end
      end
    end

    panel 'Payments (Withdrawal)' do
      table_for teacher.withdrawals.each do |t|
        t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
        t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
        t.column(:paid_on) { |withdrawal| withdrawal.date_label }
      end
    end
  end

  action_item :only => :show do
    link_to('Add Withdrawal', new_admin_payment_path(:teacher_id => teacher))
  end
end
