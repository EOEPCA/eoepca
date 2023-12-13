# Creating Groups using the Admin Dashboard

Application Hub's Admin Dashboard provides an easy and convenient way to manage groups within your  Application Hub deployment. Groups allow you to organize and control access to resources and services for different sets of users. 
Users added to a group will inherit the group's profile access controls defined in the [config.yml](https://github.com/EOEPCA/helm-charts/blob/main/charts/application-hub/files/hub/config.yml) file.

## Step 1: Access the Application Hub Admin Dashboard
- Open your web browser and navigate to the Application Hub Admin Dashboard URL. Typically, this can be accessed at `https://<domain>/hub/admin`.
- Log in using your admin credentials to access the Admin Dashboard.

## Step 2: Navigate to "Groups" Section
- Once logged in, you should see a navigation menu on the left side of the Admin Dashboard.
- Click on the "Groups" section to manage existing groups and create new ones.

## Step 3: Create a New Group
- In the "Groups" section, you'll find a list of existing groups if any have already been created.
- To create a new group, click on the "Create Group" or "Add Group" button, depending on your Application Hub version.

## Step 4: Provide Group Details
- A form will appear, prompting you to enter the details for the new group.
- Fill in the required information, such as the group name and any optional descriptions or settings.

## Step 5: Add Users to the Group (Optional)
- You have the option to add users to the newly created group.
- Look for an "Add Users" button or similar option, and select the users you want to include in the group.

## Step 6: Save the Group
- Double-check the information you entered to ensure accuracy.
- Click the "Save" or "Create" button to create the group.

Congratulations! You have successfully created a new group using the Application Hub Admin Dashboard. The new group is now available for you to assign specific resources and permissions in the [config.yml](https://github.com/EOEPCA/helm-charts/blob/main/charts/application-hub/files/hub/config.yml) file.




