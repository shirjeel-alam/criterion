ActiveAdmin::Dashboards.build do

  # section :teacher do
  #   controller.redirect_to(admin_teacher_path(current_admin_user.user))
  # end

  section :disable_dasboard, if: proc { current_admin_user.teacher? } do
    controller.redirect_to admin_teacher_path(current_admin_user.user)
  end

  section 'Quick Actions', if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? } do
    div style: 'width:20%;display:inline-block' do
      ul style: 'list-style:none' do
        li class: 'dashboard_btn' do 
          link_to 'Add A Student', new_admin_student_path, class: 'btn'
        end
        li class: 'dashboard_btn' do 
          link_to 'Find A Student', '#find_student', class: 'btn fancybox'
        end
        li class: 'dashboard_btn' do 
          link_to 'Create A Course', new_admin_course_path, class: 'btn'
        end
      end
    end

    div style: 'width:79%;display:inline-block' do
      h2 'Fee Table Here'
    end

    div style: 'clear:both'

    # Find A Student
    div style: 'display:none' do
      div id: 'find_student' do
        render 'find_student'
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
