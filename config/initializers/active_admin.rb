ActiveAdmin.setup do |config|

  # == Site Title
  #
  # Set the title that is displayed on the main layout
  # for each of the active admin pages.
  #
  config.site_title = "Criterion"


  # Set the link url for the title. For example, to take 
  # users to your main site. Defaults to no link.
  #
  config.site_title_link = "/admin"

  
  # Set an optional image to be displayed for the header
  # instead of a string (overrides :site_title)
  #
  # Note: Recommended image height is 21px to properly fit in the header
  #
  config.site_title_image = "criterion_logo_small.jpg"

  # == Default Namespace
  #
  # Set the default namespace each administration resource
  # will be added to. 
  #
  # eg: 
  #   config.default_namespace = :hello_world
  #
  # This will create resources in the HelloWorld module and
  # will namespace routes to /hello_world/*
  #
  # To set no namespace by default, use:
  #   config.default_namespace = false
  #
  # Default:
  # config.default_namespace = :admin

  # == User Authentication
  #
  # Active Admin will automatically call an authentication 
  # method in a before filter of all controller actions to 
  # ensure that there is a currently logged in admin user.
  #
  # This setting changes the method which Active Admin calls
  # within the controller.
  config.authentication_method = :authenticate_admin_user!


  # == Current User
  #
  # Active Admin will associate actions with the current
  # user performing them.
  #
  # This setting changes the method which Active Admin calls
  # to return the currently logged in user.
  config.current_user_method = :current_admin_user


  # == Logging Out
  #
  # Active Admin displays a logout link on each screen. These
  # settings configure the location and method used for the link.
  #
  # This setting changes the path where the link points to. If it's
  # a string, the strings is used as the path. If it's a Symbol, we
  # will call the method to return the path.
  #
  # Default:
  # config.logout_link_path = :destroy_admin_user_session_path

  # This setting changes the http method used when rendering the
  # link. For example :get, :delete, :put, etc..
  #
  # Default:
  # config.logout_link_method = :get


  # == Admin Comments
  #
  # Admin comments allow you to add comments to any model for admin use
  #
  # Admin comments are enabled by default in the default
  # namespace only. You can turn them on in a namesapce
  # by adding them to the comments array.
  #
  # Default:
  # config.allow_comments_in = [:admin]


  # == Controller Filters
  #
  # You can add before, after and around filters to all of your
  # Active Admin resources from here. 
  #
  # config.before_filter :do_something_awesome


  # == Register Stylesheets & Javascripts
  #
  # We recommend using the built in Active Admin layout and loading
  # up your own stylesheets / javascripts to customize the look
  # and feel.
  #
  # To load a stylesheet:
  #   config.register_stylesheet 'my_stylesheet.css'
  #
  # To load a javascript file:
  #   config.register_javascript 'my_javascript.js'
  #   config.register_javascript 'application.js'
end

module ActiveAdmin::Views::Pages
  class Base < Arbre::HTML::Document

    alias_method :original_build_active_admin_head, :build_active_admin_head unless method_defined?(:original_build_active_admin_head)

    def build_active_admin_head
      within @head do
        insert_tag Arbre::HTML::Title, [title, render_or_call_method_or_proc_on(self, active_admin_application.site_title)].join(" | ")
        active_admin_application.stylesheets.each do |style|
          text_node(stylesheet_link_tag(style.path, style.options.dup).html_safe)
        end

        active_admin_application.javascripts.each do |path|
          script :src => javascript_path(path), :type => "text/javascript"
        end
        text_node csrf_meta_tag
        # text_node(envolve_chat(current_admin_user.try(:user)).html_safe)
      end
    end

  end
end

module ActiveAdmin::Devise::Controller
  def root_path
    if Rails.env.development?
      super
    else
      if ActiveAdmin.application.default_namespace.present?
        "/criterion/#{ActiveAdmin.application.default_namespace}"
      else
        "/criterion"
      end
    end
  end
end