### Criterion Accounts ###
CriterionAccount.destroy_all

CriterionAccount.create!(account_type: CriterionAccount::BANK)
CriterionAccount.create!(account_type: CriterionAccount::CRITERION)

### Admin Users ###
AdminUser.destroy_all

AdminUser.create!(email: 'admin@criterion.edu', password: 'password', password_confirmation: 'password', role: AdminUser::SUPER_ADMIN, status: AdminUser::ACTIVE)

### Students ###
Student.destroy_all

# student = Student.new(name: 'Talib Dal', email: 'nuzaifdal@live.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
# student.phone_numbers.build(number: '03218916438', category: PhoneNumber::MOBILE)
# student.save!

# student = Student.new(name: 'Aziz Ahmed', email: 'azizahmed@hotmail.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
# student.phone_numbers.build(number: '03132000090', category: PhoneNumber::MOBILE)
# student.save!

# student = Student.new(name: 'Aisha Kudiya', email: 'aisha.kudiya@dibpak.com', address: "Gulshan-e-Iqbal Block-#{rand(15)}")
# student.phone_numbers.build(number: '03453174589', category: PhoneNumber::MOBILE)
# student.save!

### Teacher Accounts ###
Teacher.destroy_all

teachers = []
[['Kamran Abdulsalam', 0.8, 'kam_szabist@yahoo.com'], ['Adeel Iqbal', 0.8, 'kewldude_addie@hotmail.com'], ['Hussain Raza', 0.8], ['Munawar Mujahid', 0.7, 'ch_mistry@yahoo.com'], ['Moinuddin Ali', 0.8, 'mmoinuddin_ali@yahoo.com']].each do |teacher|
	teachers << Teacher.create!(name: teacher[0], share: teacher[1], email: teacher[2])
end

teachers[0].phone_numbers.create!(number: '03212309345', category: PhoneNumber::MOBILE)
teachers[1].phone_numbers.create!(number: '03222240295', category: PhoneNumber::MOBILE)
teachers[2].phone_numbers.create!(number: '03139419417', category: PhoneNumber::MOBILE)
teachers[3].phone_numbers.create!(number: '03332194885', category: PhoneNumber::MOBILE)
teachers[3].phone_numbers.create!(number: '03152008802', category: PhoneNumber::MOBILE)
teachers[4].phone_numbers.create!(number: '03002270760', category: PhoneNumber::MOBILE)

### Staff Accounts ###
Staff.destroy_all

staff = Staff.create!(name: 'Salman Dewan', email: 'salman@criterion.edu', admin_user_confirmation: 'true')
staff.phone_numbers.create!(number: '03132100200', category: PhoneNumber::MOBILE)

### Partner Accounts ###
Partner.destroy_all

partner = Partner.create!(name: 'Umair Alam', email: 'umair.alam.m@gmail.com', share: 0.5)
partner.phone_numbers.create!(number: '03138238080', category: PhoneNumber::MOBILE)

partner = Partner.create!(name: 'Ali Rana', email: 'ali_ahmed101@hotmail.com', share: 0.5)
partner.phone_numbers.create!(number: '03132012001', category: PhoneNumber::MOBILE)

### Categories ###
Category.destroy_all

['Monthly Fee', 'Registration Fee', 'Stationery', 'Gas Bill', 'Electricity Bill', 'Water Bill', 'Internet', 'Rent', 'Repairs & Maintenance', 'Office Boy', 'Capital Expenditure', 'Appropriated'].each do |category|
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