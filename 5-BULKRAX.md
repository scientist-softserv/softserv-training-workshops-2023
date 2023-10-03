![image](https://user-images.githubusercontent.com/10081604/265060617-1a3cb12c-ee6f-494e-9ed6-610135e377d2.png)

# Samvera Training Workshop - SESSION 5 - BULKRAX

0ctober 4, 2023. 8AM to 2PM PT

Welcome!

Here you'll find the workshop's concepts and exercises that are meant to go along with the commits on this branch. As you work through the exercises, you can reference the related commit(s) to check your progress. **YOU WILL NOT NEED TO CHECK OUT THIS BRANCH.**

**CONTENTS**
- [Setup Instructions](#setup-instructions)
- [Concepts](#concepts)
- [Exercises](#exercises)
  - [[1] Install Bulkrax](#1-install-bulkrax)
  - [[2] Remove non CSV parsers](#2-remove-non-csv-parsers)
---

## Setup Instructions
You can use this branch as a working example, to check your progress against as you work through the exercises

For your actual work, please checkout and make a branch off of main or continue on a branch from a previous workshop.

``` bash
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

``` bash
# Update the Bulkrax version in the Gemfile
# We are locking bulkrax to this version to ensure these instructions always apply
gem 'bulkrax', '5.4.0'

# Update bulkrax
bundle install
```
- _NOTE: since bulkrax is already in hyku, we do not have to run the generate or migrate commands found in the [bulkrax readme](https://github.com/samvera-labs/bulkrax#install-generator)._

### [2] Remove non CSV parsers
By default, bulkrax comes installed with 5 parsers. They are listed in bulkrax's ["lib/bulkrax.rb"](https://github.com/samvera-labs/bulkrax/blob/main/lib/bulkrax.rb#L104-L111) file. Visit the "/importers" endpoint and click the dropdown underneath the `Parser` heading. Here we'll see the 5 parser's listed.

However, for the purposes of this workshop, we'll only be dealing with the CSV parser, so we will remove the others. In "config/initializers/bulkrax.rb" add the code below underneath the commented out "add local parsers" section.

``` bash
# Remove local parsers
config.parsers -= [
      { name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields" },
      { name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields" },
      { name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields" },
      { name: "XML", class_name: "Bulkrax::XmlParser", partial: "xml_fields" }
    ]
```

This is a configuration change so we will not see the effect by refreshing the page. Instead we must restart the server using one of the commands below:
``` bash
# Use the restart command
docker compose exec web sh
pumactl restart -p 1

# Stop and restart the container
Ctrl-C
docker compose stop
docker compose up web
```

Refresh the page now and only the "CSV" parser should show as an option.

