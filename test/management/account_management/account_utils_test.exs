defmodule Management.AccountManager.Account.UtilsTest do
  use Management.DataCase, async: true

  alias Management.AccountManager.Account
  alias Management.AccountManager.Account.Utils

  describe "validate_email/1" do
    @tag :email_validations
    test "Success: Ensures given the a valid email address, then the changeset is valid" do
      account_changeset =
        %Account{}
        |> Account.changeset(Factory.params_for(:account))

      # ensure the changeset is valid
      assert %Changeset{valid?: true} = Utils.validate_email(account_changeset)
    end

    @tag :email_validations
    test "error: Ensures that if an invalid email address is given, the changeset is invalid" do
      account_changeset =
        %Account{}
        |> Account.changeset(
          Factory.params_for(:account)
          |> Map.put(:email, "invalid_email")
        )

      assert %Changeset{valid?: false} = changeset = Utils.validate_email(account_changeset)
      assert "Email must have the @ sign and no spaces." in errors_on(changeset).email
      assert %{email: ["Email must have the @ sign and no spaces."]} = errors_on(changeset)
    end
  end

  describe "validate_password/1" do
    @tag :password_validations
    test "Success: Ensures that given the correct password and password confirmation, the changeset returned is valid" do
      account_changeset =
        %Account{}
        |> Account.changeset(
          Factory.params_for(:account)
          |> Map.put(:password_confirmation, "randompassword12345678")
        )

      assert %Changeset{valid?: true} = Utils.validate_password(account_changeset)
    end

    @tag :password_validations
    test "error: Ensures if the password confirmation is wrong or not given, then the changeset will be invalid" do
      account_changeset =
        %Account{}
        |> Account.changeset(
          Factory.params_for(:account)
          |> Map.put(:password_confirmation, "randompassword")
        )

      assert %Changeset{valid?: false} = changeset = Utils.validate_password(account_changeset)
      assert "Passwords entered do not match." in errors_on(changeset).password_confirmation
      assert %{password_confirmation: ["Passwords entered do not match."]} = errors_on(changeset)
    end
  end

  @tag :password_validations
  test "error: Ensures if the password length is less than 8 characters, the changeset is invalid" do
    account_changeset =
      %Account{}
      |> Account.changeset(
        Factory.params_for(:account)
        # set the password too short
        |> Map.put(:password, "1234")
        |> Map.put(:password_confirmation, "1234")
      )

    assert %Changeset{valid?: false} = changeset = Utils.validate_password(account_changeset)
    assert "Password must be at least 8 characters long." in errors_on(changeset).password
    assert %{password: ["Password must be at least 8 characters long."]} = errors_on(changeset)
  end
end
