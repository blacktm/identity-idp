class TwoFactorOptionsPresenter
  include ActionView::Helpers::TranslationHelper

  attr_reader :current_user, :service_provider

  def initialize(current_user, sp)
    @current_user = current_user
    @service_provider = sp
  end

  def title
    t("titles.two_factor_#{recovery}setup")
  end

  def heading
    t("two_factor_authentication.two_factor_#{recovery}choice")
  end

  def info
    t("two_factor_authentication.two_factor_#{recovery}choice_intro")
  end

  def label
    t("forms.two_factor_#{recovery}choice.legend") + ':'
  end

  def options
    phone_options + totp_option + webauthn_option + piv_cac_option + backup_code_option
  end

  private

  def recovery
    no_factors_enabled? ? '' : 'recovery_'
  end

  def no_factors_enabled?
    MfaPolicy.new(current_user).no_factors_enabled?
  end

  def phone_options
    if TwoFactorAuthentication::PhonePolicy.new(current_user).available?
      [
        TwoFactorAuthentication::SmsSelectionPresenter.new,
        TwoFactorAuthentication::VoiceSelectionPresenter.new,
      ]
    else
      []
    end
  end

  def webauthn_option
    if TwoFactorAuthentication::WebauthnPolicy.new(current_user).available?
      [TwoFactorAuthentication::WebauthnSelectionPresenter.new]
    else
      []
    end
  end

  def totp_option
    if TwoFactorAuthentication::AuthAppPolicy.new(current_user).available?
      [TwoFactorAuthentication::AuthAppSelectionPresenter.new]
    else
      []
    end
  end

  def piv_cac_option
    policy = TwoFactorAuthentication::PivCacPolicy.new(current_user)
    return [] if policy.enabled?
    return [] unless policy.available? || service_provider&.piv_cac_available?(current_user)
    [TwoFactorAuthentication::PivCacSelectionPresenter.new]
  end

  def backup_code_option
    policy = TwoFactorAuthentication::BackupCodePolicy.new(current_user)
    return [TwoFactorAuthentication::BackupCodeSelectionPresenter.new] if policy.available?
    []
  end
end
