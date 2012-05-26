### Criterion Accounts ###
CriterionAccount.destroy_all

CriterionAccount.create!(account_type: CriterionAccount::BANK)
CriterionAccount.create!(account_type: CriterionAccount::CRITERION)

### Admin Users ###
AdminUser.destroy_all

AdminUser.create!(email: 'admin@criterion.edu', password: 'password', password_confirmation: 'password', role: AdminUser::SUPER_ADMIN, status: AdminUser::ACTIVE)

### Students ###
Student.destroy_all

student = Student.create!(name: 'Talib Dal', email: 'nuzaifdal@live.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
student.phone_numbers.create!(number: '03218916438', category: PhoneNumber::MOBILE)

student = Student.create!(name: 'Aziz Ahmed', email: 'azizahmed@hotmail.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
student.phone_numbers.create!(number: '03132000090', category: PhoneNumber::MOBILE)

student = Student.create!(name: 'Aisha Kudiya', email: 'aisha.kudiya@dibpak.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
student.phone_numbers.create!(number: '03453174589', category: PhoneNumber::MOBILE)

### Teacher Accounts ###
Teacher.destroy_all

[['Kamran Abdulsalam', 0.8], ['Adeel Iqbal', 0.8], ['Hussain Raza', 0.8], ['Munawar Mujahid', 0.7], ['Moinuddin Ali', 0.8]].each do |teacher|
	Teacher.create!(name: teacher[0], share: teacher[1])
end

### Staff Accounts ###
Staff.destroy_all

Staff.create!(name: 'Salman Dewan', email: 'salman@criterion.edu', admin_user_confirmation: 'true')

### Partner Accounts ###
Partner.destroy_all

Partner.create!(name: 'Umair Alam', email: 'umair@criterion.edu', share: 0.5)
Partner.create!(name: 'Ali Rana', email: 'ali@criterion.edu', share: 0.5)

### Categories ###
Category.destroy_all

['Stationery', 'Gas Bill', 'Electricity Bill', 'Water Bill', 'Internet', 'Rent', 'Repairs & Maintenance', 'Office Boy', 'Capital Expenditure', 'Appropriated'].each do |category|
	Category.create!(name: category)
end

### Sessions ###
Session.destroy_all

curr_year = Date.today.year
5.times do
	[Session::MAY_JUNE, Session::OCT_NOV].each do |period|
		Session.create!(period: period, year: curr_year, registration_fee: 500)
	end
	curr_year += 1
end