Warden::Manager.after_set_user do |record, warden, options|
  record.update_column(:signed_in, true) rescue nil
end

Warden::Manager.before_logout do |record, warden, options|
  record.update_column(:signed_in, false) rescue nil
end
