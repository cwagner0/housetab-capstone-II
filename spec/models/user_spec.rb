require "rails_helper"

RSpec.describe User, type: :model do
  describe "#net_balance_with" do
    let(:household) { create(:household) }
    let(:charlie)   { create(:user, name: "Charlie") }
    let(:jimmy)     { create(:user, name: "Jimmy") }

    before do
      create(:membership, user: charlie, household: household, role: "admin")
      create(:membership, user: jimmy,   household: household)
    end

    context "when Jimmy owes Charlie $10 on a single expense" do
      before do
        expense = create(:expense, household: household, payer: charlie, total_amount: 20.00)
        create(:split, expense: expense, user: jimmy, amount_owed: 10.00)
      end

      it "returns +10.00 from Charlie's perspective" do
        expect(charlie.net_balance_with(jimmy, household)).to eq(10.00)
      end

      it "returns -10.00 from Jimmy's perspective" do
        expect(jimmy.net_balance_with(charlie, household)).to eq(-10.00)
      end
    end

    context "when Jimmy and Charlie owe each other equal amounts" do
      before do
        e1 = create(:expense, household: household, payer: charlie, total_amount: 20.00)
        create(:split, expense: e1, user: jimmy, amount_owed: 10.00)

        e2 = create(:expense, household: household, payer: jimmy, total_amount: 20.00)
        create(:split, expense: e2, user: charlie, amount_owed: 10.00)
      end

      it "nets to zero" do
        expect(charlie.net_balance_with(jimmy, household)).to eq(0)
      end
    end

    context "when a confirmed settlement reduces what Jimmy owes" do
      before do
        expense = create(:expense, household: household, payer: charlie, total_amount: 20.00)
        create(:split, expense: expense, user: jimmy, amount_owed: 10.00)

        create(:settlement,
          household: household,
          sender: jimmy, recipient: charlie,
          amount: 10.00, status: "confirmed")
      end

      it "shows Jimmy as settled with Charlie" do
        expect(charlie.net_balance_with(jimmy, household)).to eq(0)
      end
    end

    context "when a settlement is still pending" do
      before do
        expense = create(:expense, household: household, payer: charlie, total_amount: 20.00)
        create(:split, expense: expense, user: jimmy, amount_owed: 10.00)

        create(:settlement,
          household: household,
          sender: jimmy, recipient: charlie,
          amount: 10.00, status: "pending")
      end

      it "still shows Jimmy as owing $10 (pending doesn't count)" do
        expect(charlie.net_balance_with(jimmy, household)).to eq(10.00)
      end
    end
  end
end
