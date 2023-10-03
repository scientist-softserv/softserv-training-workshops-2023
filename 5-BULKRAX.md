![image](https://user-images.githubusercontent.com/10081604/265060617-1a3cb12c-ee6f-494e-9ed6-610135e377d2.png)

# Samvera Training Workshop - SESSION 5 - BULKRAX

0ctober 4, 2023. 8AM to 2PM PT

Welcome!

Here you'll find the workshop's concepts and exercises that are meant to go along with the commits on this branch. As you work through the exercises, you can reference the related commit(s) to check your progress. **YOU WILL NOT NEED TO CHECK OUT THIS BRANCH.**

**CONTENTS**
- [Setup Instructions](#setup-instructions)
- [Concepts](#concepts)
- [Exercises](#exercises)
---

## Setup Instructions
You can use this branch as a working example, to check your progress against as you work through the exercises

For your actual work, please checkout and make a branch off of main or continue on a branch from a previous workshop.

```
git clone https://github.com/scientist-softserv/softserv-training-workshops-2023
git checkout main
git checkout -b branch-name
```

### Running the Stack
If you're unfamiliar with the Hyku application, please refer to the "HYKU README" section at the bottom of the [README](./README.md) on this branch.

### Create a Tenant

After running migrations and seeds, `rails db:migrate db:seed`, create a tenant.

Admin login:
  username - admin@example.com
  password - testing123

Visit `hyku.test/proprietor/accounts?locale=en`. Click "Create new account" to enter a name and save.
- After creating a new account, click Edit, check "Ssl configured" and "Save Changes"
- Visit your tenant's site by prepending the tenant name to `hyku.test`. Example: `https://dev.hyku.test`

  - :warning: **if you see a pop up box asking for credentials, the user name is _"samvera"_ and the password is _"hyku"_**.

## Concepts
### What is bulkrax?
Bulkrax is a batteries included importer for Samvera applications. It currently includes support for OAI-PMH (DC and Qualified DC) and CSV out of the box. It is also designed to be extensible, allowing you to easily add new importers in to your application or to include them with other gems. Bulkrax provides a full admin interface including creating, editing, scheduling and reviewing imports.
## Exercises
### [1] Install bulkrax
Today we will be working from the latest released version, [v5.4.0](https://github.com/samvera-labs/bulkrax/releases/tag/v5.4.0)

```
# Update the Bulkrax version in the Gemfile
# We are locking bulkrax to this version to ensure these instructions always apply
gem 'bulkrax', '5.4.0'

# Update bulkrax
bundle install
```
- _NOTE: since bulkrax is already in hyku, we do not have to run the generate or migrate commands found in the [bulkrax readme](https://github.com/samvera-labs/bulkrax#install-generator)._


