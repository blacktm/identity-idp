require 'rails_helper'

feature 'recovery welcome step' do
  include IdvStepHelper
  include DocAuthHelper
  include RecoveryHelper

  let(:user) { create(:user) }
  let(:profile) { build(:profile, :active, :verified, user: user, pii: { ssn: '1234' }) }

  before do
    enable_doc_auth
    sign_in_before_2fa(user)
    complete_recovery_steps_before_welcome_step(user)
  end

  it 'is on the correct page' do
    expect(page).to have_current_path(idv_recovery_welcome_step)
    expect(page).to have_content(t('doc_auth.instructions.welcome'))
  end

  it 'proceeds to the next page' do
    click_on t('doc_auth.buttons.get_started')
    expect(page).to have_current_path(idv_recovery_upload_step)
  end
end