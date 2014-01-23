class UserPresenter < Presenter
  allow :phone, :udid, :token, :locale, :version, :timezone, :bundle
end
