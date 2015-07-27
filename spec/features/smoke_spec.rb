require 'rails_helper'

feature 'It dosent smoke' do
  scenario 'Visiting home' do
    visit '/'
    expect(page.status_code).to be 200
  end
end

