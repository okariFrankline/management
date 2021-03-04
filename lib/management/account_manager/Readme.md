# Creating a new account:

    1. Input recieved must include email address, account type, password, password_hash
    2. The data is validated using changeset.
    3. Create an activation token, store in the db and generate an   activation link
    3. The data is inserted into the db:
       => If successful, an activation email is sent to the user.
       => If unsuccessful, an error tuple is sent to the user.
