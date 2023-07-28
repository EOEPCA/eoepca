# Open id Creation

In this section, we will guide you through the process of setting up the ApplicationHub OpenID client on Gluu. By following these steps, you'll be able to authenticate users securely using OpenID Connect. Let's get started:

## Step 1: Log in to the Gluu Admin Dashboard
- Open your web browser and navigate to the Gluu Admin Dashboard.
- Enter your admin credentials to log in.

## Step 2: Configure Sector Identifier
- Once logged in, go to **OpenID Connect** -> **Sector Identifier** in the Gluu Admin Dashboard.
- Click on the **Add Sector Identifier** button.
- Fill out the form with the following details:
    - **Description**: ApplicationHub
    - **Redirect Login URIs**: `https://applicationhub.demo.eoepca.org/hub/oauth_callback`
- Click the **Add/Update** button to save the sector identifier configuration.

## Step 3: Create the OpenID Client
- Now, navigate to **OpenID Connect** -> **Clients** in the Gluu Admin Dashboard.
- Click on the **Add client** button.
- Fill out the form with the following information:
    - **Client Name**: ApplicationHub
    - **Client Secret**: `<client_secret>` (Replace `<client_secret>` with your actual secret value.)
    - **Redirect Login URIs**: `https://applicationhub.<domain>/hub/oauth_callback`
    - **Scopes**: `[openid, email, user_name, is_operator]`
    - **Response Types**: `[code, token, id_token]`
    - **Persist Client Authorizations**: Disabled
    - **Grant Types**: `[authorization_code, implicit, client_credentials, refresh_token, password]`
    - **Redirect Logout URIs**: `https://<domain>/`
    - **Set Identifier URI**: ApplicationHub identifier (You can set this to an appropriate value for your ApplicationHub.)
- Click the **Add/Update** button to save the client configuration.

Congratulations! You have successfully created the ApplicationHub OpenID client on Gluu. The client is now ready to securely authenticate users through OpenID Connect.

Please proceed to the next step: [Sealed secrets creation](sealed_secrets.md)