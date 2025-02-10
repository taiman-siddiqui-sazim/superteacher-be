subjects = %w[Physics Mathematics Chemistry Biology English Bangla]

subjects.each do |subject|
  Subject.find_or_create_by(subject: subject)
end
