namespace :criterion do
  desc "Generate sessions"
  task :generate_sessions, [:period] => :environment do |t, args|
    MAY_JUNE = 0
    OCT_NOV = 1

    REGISTRATION_FEE = [1000, 800, 1200]

    args.with_defaults(period: 50)

    args[:period].to_i.times do |i|
      curr_year = (Time.current.to_date + (i + 1).years).year
      Session.create(period: MAY_JUNE, year: curr_year, registration_fee: REGISTRATION_FEE[rand(REGISTRATION_FEE.length)])
      Session.create(period: OCT_NOV, year: curr_year, registration_fee: REGISTRATION_FEE[rand(REGISTRATION_FEE.length)])
    end
  end

  desc "Generate development data"
  task generate_development_data: :environment do
    # 3 Students, 3 Teachers, 3 Courses, 6 Sessions

    Rake::Task["db:migrate:reset"].reenable
    Rake::Task["db:migrate:reset"].invoke

    SHARE = [0.6, 0.65, 0.7, 0.75, 0.8]
    MONTHLY_FEE = [1500, 2000, 2500, 3000]
    COURSE_NAME = ["Economics A-Level", "Accounting O-Level", "Physics A-Level", "Statistics O-Level", "Urdu O-Level", "Maths A-Levels"]

    Rake::Task["criterion:generate_sessions"].reenable
    Rake::Task["criterion:generate_sessions"].invoke(2)

    3.times do
      student = Student.create(name: Faker::Name.name, address: Faker::Address.street_address)
      PhoneNumber.create(number: Faker::PhoneNumber.phone_number[0..10], category: rand(4), contactable_id: student.id, contactable_type: student.class.name)

      teacher = Teacher.create(name: Faker::Name.name, share: SHARE[rand(SHARE.length)])
      PhoneNumber.create(number: Faker::PhoneNumber.phone_number[0..10], category: rand(4), contactable_id: teacher.id, contactable_type: teacher.class.name)

      Course.create(name: COURSE_NAME[rand(COURSE_NAME.length)], teacher_id: Teacher.all[rand(Teacher.count)].id, session_id: Session.all[rand(Session.count)].id, monthly_fee: MONTHLY_FEE[rand(MONTHLY_FEE.length)])
    end
  end

  desc "Generate default categories"
  task generate_categories: :environment do
    ['student fee', 'teacher fee', 'bills', 'stationery', 'misc'].each do |category|
      Category.find_or_create_by_name(category)
    end
  end

  desc "Clear SMS and Emails"
  task clear_sms_and_email: :environment do
    CriterionSms.destroy_all
    CriterionMail.destroy_all
  end

  desc "Copy current balance to initial balance"
  task copy_balances: :environment do
    CriterionAccount.all.each do |criterion_account|
      criterion_account.update_attribute(:initial_balance, criterion_account.balance)
    end
  end

  desc "Reset Passwords"
  task reset_passwords: :environment do
    if Rails.env.development?
      AdminUser.all.each do |user|
        user.password = 'password'
        user.save!
      end
    end
  end

  desc "Criterion Account CSV"
  task criterion_account_csv: :environment do
    require 'csv'

    CSV.open("criterion-account-#{Time.now}.csv", 'w') do |csv|
      csv << ['ID', 'Date', 'Particular', 'Payment', 'Debit', 'Credit', 'Balance']

      criterion_account = CriterionAccount.criterion_account
      criterion_account.account_entries.each do |account_entry|
        debit = account_entry.debit? ? account_entry.amount : nil
        credit = account_entry.credit? ? account_entry.amount : nil
        running_balance = criterion_account.running_balance(account_entry.id)
        csv << [account_entry.id, account_entry.created_at.strftime('%d %B, %Y'), account_entry.payment.particular_extended, account_entry.payment_id, debit, credit, running_balance]
      end
    end
  end

  desc "Criterion Account Balances CSV"
  task criterion_account_balances_csv: :environment do
    require 'csv'

    CSV.open("criterion-account-balances-#{Time.now}.csv", 'w') do |csv|
      csv << ['Account Holder', 'Balance']

      CriterionAccount.find_each do |account|
        csv << [(account.admin_user.user.name rescue nil), account.balance]
      end
    end
  end
end
