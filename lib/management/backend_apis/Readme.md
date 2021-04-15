# This folder holds all the Interfaces for interacting with the backend.

## Reasons:

=> Ensuring that phoenix controllers/liveviews/channels remain as thin as possible.

### How the folder files are structured:

=> Each file provides an API for a single context and only intertwining whenever necessary.
e.g. account_manager.api.ex provides an api for functionalities only for managing an Account such as registering, login in, password reset, etc.

###### Andrew Kagia, Frank Miller

=> Login in the user:

1. Get the user with the email address
2. if the user exists, check the password, if the password is correct, return the account.
3. If the password is wrong/ the user is does not exist, fake a password check and rern an error tuple
4. if te user does not

#### Accepting an invitation by the writer to join a team of an account owner

1. Check the token is valid for the account owner (Is not expired or does not exist)
2. Add the id of the account owner to the membership_teams of the writer.
3. Delete the token with from the account owner.
4. Return the updated profile to the user
