ActiveAdmin.register PhoneNumber do
	menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin? }
end
