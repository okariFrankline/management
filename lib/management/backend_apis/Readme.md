# This folder holds all the Interfaces for interacting with the backend.

## Reasons:

=> Ensuring that phoenix controllers/liveviews/channels remain as thin as possible.

### How the folder files are structured:

=> Each file provides an API for a single context and only intertwining whenever necessary.
e.g. account_manager.api.ex provides an api for functionalities only for managing an Account such as registering, login in, password reset, etc.

###### Andrew Kagia, Frank Miller
