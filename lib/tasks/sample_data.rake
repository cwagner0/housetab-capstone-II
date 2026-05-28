desc "Fill the database tables with some sample data"
task({ sample_data: :environment }) do
  starting = Time.now

  puts "Clearing old data..."
  Settlement.destroy_all
  Split.destroy_all
  Expense.destroy_all
  Membership.destroy_all
  Household.destroy_all
  User.destroy_all

  puts "Creating users..."
  charlie = User.create!(name: "Charlie", email: "charlie@example.com", password: "password")
  jimmy   = User.create!(name: "Jimmy",   email: "jimmy@example.com",   password: "password")
  olivia  = User.create!(name: "Olivia",  email: "olivia@example.com",  password: "password")
  tom     = User.create!(name: "Tom",     email: "tom@example.com",     password: "password")

  puts "Creating household..."
  apt = Household.create!(name: "Apt 4B")

  puts "Adding members..."
  Membership.create!(user: charlie, household: apt, role: "admin")
  Membership.create!(user: jimmy,   household: apt, role: "member")
  Membership.create!(user: olivia,  household: apt, role: "member")
  Membership.create!(user: tom,     household: apt, role: "member")

  puts "Creating expenses..."

  # Expense 1: Charlie paid, split with Jimmy and Olivia
  e1 = Expense.create!(
    household: apt, payer: charlie,
    description: "Trader Joe's groceries",
    total_amount: 67.42, store_name: "Trader Joe's",
    date: Date.new(2026, 2, 28), notes: "Weekly groceries run"
  )
  Split.create!(expense: e1, user: jimmy,  amount_owed: 22.47)
  Split.create!(expense: e1, user: olivia, amount_owed: 22.47)

  # Expense 2: Jimmy paid, split 4 ways
  e2 = Expense.create!(
    household: apt, payer: jimmy,
    description: "Thai takeout dinner",
    total_amount: 48.90, store_name: "Pad Thai Palace",
    date: Date.new(2026, 2, 27)
  )
  per_person = (48.90 / 4).round(2)
  Split.create!(expense: e2, user: charlie, amount_owed: per_person)
  Split.create!(expense: e2, user: olivia,  amount_owed: per_person)
  Split.create!(expense: e2, user: tom,     amount_owed: 48.90 - (per_person * 3))

  # Expense 3: Olivia paid, split 4 ways
  e3 = Expense.create!(
    household: apt, payer: olivia,
    description: "Paper towels & cleaning supplies",
    total_amount: 22.15, store_name: "Target",
    date: Date.new(2026, 2, 26)
  )
  per_person = (22.15 / 4).round(2)
  Split.create!(expense: e3, user: charlie, amount_owed: per_person)
  Split.create!(expense: e3, user: jimmy,   amount_owed: per_person)
  Split.create!(expense: e3, user: tom,     amount_owed: 22.15 - (per_person * 3))

  # Expense 4: Tom paid, split with Charlie only
  e4 = Expense.create!(
    household: apt, payer: tom,
    description: "Costco run — bulk items",
    total_amount: 134.88, store_name: "Costco",
    date: Date.new(2026, 2, 24)
  )
  Split.create!(expense: e4, user: charlie, amount_owed: 67.44)

  # Expense 5: Charlie paid, split 4 ways
  e5 = Expense.create!(
    household: apt, payer: charlie,
    description: "Domino's pizza night",
    total_amount: 38.50, store_name: "Domino's",
    date: Date.new(2026, 2, 22)
  )
  per_person = (38.50 / 4).round(2)
  Split.create!(expense: e5, user: jimmy,  amount_owed: per_person)
  Split.create!(expense: e5, user: olivia, amount_owed: per_person)
  Split.create!(expense: e5, user: tom,    amount_owed: 38.50 - (per_person * 3))

  # Expense 6: Olivia paid, split 4 ways
  e6 = Expense.create!(
    household: apt, payer: olivia,
    description: "Amazon — shower curtain",
    total_amount: 19.99, store_name: "Amazon",
    date: Date.new(2026, 2, 20)
  )
  per_person = (19.99 / 4).round(2)
  Split.create!(expense: e6, user: charlie, amount_owed: per_person)
  Split.create!(expense: e6, user: jimmy,   amount_owed: per_person)
  Split.create!(expense: e6, user: tom,     amount_owed: 19.99 - (per_person * 3))

  puts "Creating settlements..."

  # Jimmy already settled $20 with Charlie (confirmed)
  Settlement.create!(
    household: apt, sender: jimmy, recipient: charlie,
    amount: 20.00, note: "Caught up",
    status: "confirmed", confirmed_at: Time.new(2026, 2, 25)
  )

  # Jimmy sent another $45 (pending Charlie's confirmation)
  Settlement.create!(
    household: apt, sender: jimmy, recipient: charlie,
    amount: 45.00, note: "Feb groceries",
    status: "pending"
  )

  # Charlie paid Olivia (pending her confirmation)
  Settlement.create!(
    household: apt, sender: charlie, recipient: olivia,
    amount: 11.25, note: "Cleaning supplies",
    status: "pending"
  )

  ending = Time.now
  puts "Sample data created in #{(ending - starting).round(2)}s."
  puts ""
  puts "Login credentials (password is 'password' for all):"
  puts "  charlie@example.com"
  puts "  jimmy@example.com"
  puts "  olivia@example.com"
  puts "  tom@example.com"
  puts ""
  puts "Household: Apt 4B"
  puts "Invite code: #{apt.invite_code}"
end
