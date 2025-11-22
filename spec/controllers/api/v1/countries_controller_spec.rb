# frozen_string_literal: true

RSpec.describe Api::V1::CountriesController, type: :controller do
  describe 'GET #index' do
    subject(:do_action) { get :index }

    let(:owner) { create(:user, :owner) }
    let(:academies) do
      [
        create(:academy, country: 'US', user: owner),
        create(:academy, country: 'IE', user: owner),
        create(:academy, country: 'GB', user: owner)
      ]
    end

    before { academies }

    it 'returns http success' do
      do_action
      expect(response).to have_http_status(:ok)
    end

    it 'returns a unique, sorted list of countries' do
      do_action
      json = JSON.parse(response.body)

      expect(json).to be_an(Array)
      expect(json.count).to eq(3)
      expect(json).to include({ 'value' => 'GB', 'label' => 'GB' })
      expect(json).to include({ 'value' => 'IE', 'label' => 'IE' })
      expect(json).to include({ 'value' => 'US', 'label' => 'US' })
    end
  end
end
