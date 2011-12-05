ActiveAdmin.register Teacher do
  filter :id
  filter :name
  filter :share
  
  index do
    column 'ID' do |teacher|
      link_to(teacher.id, admin_teacher_path(teacher))
    end
    column :name
    column :share
  end
end
