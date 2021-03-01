defmodule Management.Authentication.Guardian do
  use Guardian, otp_app: :management

  alias Management.AccountManager
  alias Management.AccountManager.Account

  @doc false
  def subject_for_token(%Account{id: id} = _account, _claims) do
    {:ok, to_string(id)}
  end

  @doc false
  def resource_from_claims(%{"sub" => id} = _claims) do
    account = AccountManager.get_account!(id)

    {:ok, account}
  rescue
    Ecto.NoResultsError ->
      {:error, :no_resource}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
