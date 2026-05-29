require "rails_helper"

RSpec.describe "Households", type: :request do
  let(:apt)       { create(:household) }
  let(:member)    { create(:user) }
  let(:outsider) { create(:user) }

  before do
    create(:membership, user: member, household: apt, role: "admin")
  end

  describe "GET /households/:id" do
    context "as a member" do
      it "renders the show page" do
        sign_in member
        get household_path(apt)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(apt.name)
      end
    end

    context "as a non-member" do
      it "redirects to the root path with an alert" do
        sign_in outsider
        get household_path(apt)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("have access to that")
      end
    end

    context "when signed out" do
      it "redirects to sign in" do
        get household_path(apt)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
