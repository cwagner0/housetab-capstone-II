# HouseTab

A roommate expense-sharing app for households of 2-8 people. Snap a receipt, the AI fills in the form, split with the right roommates, and always know who owes whom.

Built for the Full-stack App & AI Development II capstone (Spring 2026).

## What it solves

Roommates constantly share expenses (groceries, household supplies, dinners) but tracking who owes whom is messy. Venmo requests get lost, spreadsheets go stale, someone always feels like they're paying more than their share. HouseTab keeps a running tab from receipt photos so everyone can see exactly what was bought, who it was for, and what's owed, with no pressure to settle on any particular schedule.

## Critical flows

1. Sign in, see your dashboard with current balances and recent expenses.
2. Add an expense: snap or upload the receipt photo. A background job sends the image to GPT-4o-mini, which reads the receipt and fills in the store, total, date, and description automatically.
3. Pick which roommates split this expense. Live calculator shows the per-person share.
4. Save, and every roommate's dashboard updates instantly via Turbo Streams.
5. Log a settlement when someone pays you back. The recipient confirms or disputes, balances recalc live.
6. Non-members are blocked from viewing your household by ActionPolicy.

## Tech stack

- Rails 8.0 on Ruby 4.0
- PostgreSQL
- Devise for authentication
- ActionPolicy for authorization
- Active Storage for receipt photos
- Solid Queue for background jobs (AI receipt scan)
- Solid Cable + Turbo Streams for live updates across browsers
- Stimulus for the live split calculator
- OpenAI gpt-4o-mini for receipt scanning (Chat Completions vision API)
- RSpec + FactoryBot for tests
- Bootstrap 5 for styling
- Render for production deployment

## Running locally

You'll need Ruby 4.0.1, PostgreSQL, and an OpenAI API key.

```bash
bundle install
bin/rails db:create db:migrate
bin/rails sample_data
echo "OPENAI_API_KEY=sk-your-key-here" > .env
bin/rails server
```

Visit http://localhost:3000 and sign in as `charlie@example.com` / `password`.

## Demo credentials

After running the seed task, four users exist (password is `password` for all):

- charlie@example.com (admin of Apt 4B)
- jimmy@example.com
- olivia@example.com
- tom@example.com

## Tests

```bash
bundle exec rspec
```

## Future work (V2)

These are intentional scope cuts for the capstone, documented for transparency:

- **Per-item split assignment**: Currently the receipt is split evenly across selected roommates. V2 would extract individual line items from the receipt (the AI returns them already, we just don't surface them) and let you assign each item to specific roommates. Use case: you go to Dick's Sporting Goods and buy a cornhole set (split with the whole house) plus two pickleball rackets (split between only two roommates).
- **Recurring expenses**: Rent, utilities, and subscriptions don't change much month to month. V2 would let you define a recurring expense template with a cadence, and a daily background job would generate the new expense.
- **Hotwire Native mobile app**: The web app already works on mobile. A native wrapper using Hotwire Native would give roommates push notifications and faster receipt photo capture.
- **Multi-household support**: Right now the dashboard shows your first household. V2 would let you belong to multiple households (e.g., your apartment plus your beach house with college friends) and switch between them.
