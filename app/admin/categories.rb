ActiveAdmin.register Category do
	menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin_or_partner? }

	filter :id
	filter :name
	
	index do
		column 'ID', :sortable => :id do |category|
			link_to(category.id, admin_category_path(category))
		end
		column :name, :sortable => :name do |category|
			category.name_label
		end

		default_actions
	end
	
	show :title => :name_label do  
		panel 'Category Details' do
			attributes_table_for category do
				row(:id) { category.id }
				row(:name) { category.name_label }
			end
		end
	end
end
