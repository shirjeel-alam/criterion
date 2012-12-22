class AddPartnerIdToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :partner_id, :integer
  end
end
