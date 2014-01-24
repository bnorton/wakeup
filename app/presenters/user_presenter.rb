class UserPresenter < Presenter
  allow :phone, :udid, :token, :locale, :version, :timezone, :bundle, :verified_at
end
