ActiveAdmin.register Book do
  menu priority: 2

  index do
    column 'ID', sortable: :id do |book|
      link_to(book.id, admin_book_path(book))
    end
    column :name
    column :course, sortable: :course_id do |book|
      book.course.name rescue nil
    end
    column :teacher do |book|
      book.course.teacher.name
    end
    column :share, sortable: :share do |book|
      number_to_percentage(book.share * 100, precision: 0)
    end if current_admin_user.super_admin_or_partner?
    column :amount, sortable: :amount do |book|
			number_to_currency(book.amount, unit: 'Rs. ', precision: 0)
		end

    default_actions
  end

  show title: :title do
    panel 'Book Details' do
      attributes_table_for book do
        row(:id) { book.id }
        row(:name) { book.name }
        row(:course) { link_to(book.course.name, admin_course_path(book.course)) rescue nil }
        row(:teacher) { link_to(book.course.teacher.name, admin_teacher_path(book.course.teacher)) rescue nil }
        row(:share) { number_to_percentage(book.share * 100, precision: 0) }
        row(:amount) { number_to_currency(book.amount, unit: 'Rs. ', precision: 0) }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :course, collection: Course.get_all, input_html: { class: 'chosen-select' }
      f.input :name
      f.input :amount
      f.input :share, required: false, step: 0.05, hint: 'If left empty will use books existing share value'
    end

    f.buttons
  end
end
