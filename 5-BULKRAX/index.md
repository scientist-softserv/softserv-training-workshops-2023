![image](https://user-images.githubusercontent.com/10081604/265060617-1a3cb12c-ee6f-494e-9ed6-610135e377d2.png)

# Samvera Training Workshop - SESSION 5 - BULKRAX

0ctober 4, 2023. 8AM to 2PM PT

Welcome!

Bulkrax is a batteries included importer for Samvera applications. It currently includes support for OAI-PMH (DC and Qualified DC) and CSV out of the box. It is also designed to be extensible, allowing you to easily add new importers in to your application or to include them with other gems. Bulkrax provides a full admin interface including creating, editing, scheduling and reviewing imports.

Here you'll find the workshop's concepts and exercises that are meant to go along with the commits on this branch. As you work through the exercises, you can reference the related commit(s) to check your progress. **YOU WILL NOT NEED TO CHECK OUT THIS BRANCH.**

**CONTENTS**
- [Setup Instructions](#setup-instructions)
- [Bulkrax Concepts](#bulkrax-concepts)
- [Background Jobs](#background-jobs)
- [Exercises](#exercises)
  - [[1] Install Bulkrax](#1-install-bulkrax)
  - [[2] Remove non CSV Parsers](#2-remove-non-csv-parsers)
  - [[3] Import Required Fields Only](#3-import-required-fields-only)
  - [[4] Import Fields Without Custom Mapping](#4-import-fields-without-custom-mapping)
  - [[5] Import a Comples CSV](#5-import-fields-with-custom-mapping)
  - [[6] Export](#6-export)
  - [[7] Round Trip](#7-round-trip)
---

## Setup Instructions
You can use this branch as a working example, to check your progress against as you work through the exercises

For your actual work, please checkout and make a branch off of main or continue on a branch from a previous workshop.

``` bash
git clone https://github.com/scientist-softserv/softserv-training-workshops-2023
git checkout main
git checkout -b branch-name
```

_NOTE: Either way, please pull `main` again as there have been some updates._

### Running the Stack
If you're unfamiliar with the Hyku application, please refer to the "HYKU README" section at the bottom of the [README](../README.md) to get it running.

<details>
<summary>If you haven't already, create a tenant</summary>

Run `rails db:migrate db:seed`.

Admin login:
  username - `ENV[INITIAL_ADMIN_EMAIL]`
  password - `ENV[INITIAL_ADMIN_PASSWORD]`

Visit `hyku.test/proprietor/accounts?locale=en`. Click "Create new account" to enter a name and save.
- After creating a new account, click Edit, check "Ssl configured" and "Save Changes"
- Visit your tenant's site by prepending the tenant name to `hyku.test`. Example: `https://dev.hyku.test`

  - :warning: _if you see a pop up box asking for credentials, the user name is **"samvera"** and the password is **"hyku"**._
</details>

## Bulkrax Concepts
- [Field Mappings](https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#field-mappings)
- [Work identifier](https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#work-identifier)
- [Source identifier](https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#source-identifier)
- [Parent/Child Relationships](https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#parent-child-relationship-field-mappings)
- [Exporting](https://github.com/samvera-labs/bulkrax/wiki/CSV-Exporter#exporting)
- [Round Tripping](https://github.com/samvera-labs/bulkrax/wiki/CSV-Exporter#round-tripping)
- [Troubleshooting](https://github.com/samvera-labs/bulkrax/wiki/Troubleshooting)

## Background Jobs
> "One of the many powerful features of Rails is its support for background jobs, which allow you to run specific tasks asynchronously in the background without blocking the main thread of execution.
>
> Background jobs are especially useful for tasks that take a long time to complete, such as sending emails, processing images, or generating reports. Using background jobs, you can ensure that your application remains responsive and can continue handling incoming requests even while these long-running tasks are being performed.
>
> There are several different ways to implement background jobs in Ruby on Rails. The most common approach is using a gem such as Sidekiq, Delayed Job, etc., which provides a simple and efficient way to manage your background jobs. These gems make it easy to enqueue jobs, set priorities, and track their progress." [Source](https://web-crunch.com/posts/how-to-use-background-jobs-ruby-on-rails)

Hyku uses Sidekiq as its background job processor and is already installed.

## Exercises
### [1] Install bulkrax
Today we will be working from the latest released version, [v5.4.1](https://github.com/samvera-labs/bulkrax/releases/tag/v5.4.0)

``` bash
# Update the Bulkrax version in the Gemfile
# We are locking bulkrax to this version to ensure these instructions always apply
gem 'bulkrax', '5.4.1'

# Update bulkrax
bundle install
```
> _NOTE: since bulkrax is already in hyku, we do not have to run the generate or migrate commands found in the [bulkrax readme](https://github.com/samvera-labs/bulkrax#install-generator)._

### [2] Remove non CSV Parsers
By default, bulkrax comes installed with 5 parsers. They are listed in the bulkrax config file (["lib/bulkrax.rb"](https://github.com/samvera-labs/bulkrax/blob/main/lib/bulkrax.rb#L104-L111)). A similar config file exists in your app at [config/initializers/bulkrax.rb](../config/initializers/bulkrax.rb). Visit the "/importers" endpoint and click the dropdown underneath the `Parser` heading. Here we'll see the 5 parser's listed.

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

## OR

# Stop and restart the container
Ctrl-C
docker compose stop
docker compose up web
```

Refresh the page now and only the "CSV" parser should show as an option.

### [3] Import Required Fields Only
Looking back at bulkrax's config file, we see that some parsers already include a few field mappings. The `Bulkrax::CsvParser` is not one of them. However, Hyku resets all parsers to only have the same 2 field mappings by default: `parents` and `children`. We can then build upon that mapping for each parser as we see fit.

To begin with, we will import a CSV with only the required elements. Hyku requires the [title](https://github.com/samvera-labs/bulkrax/blob/main/lib/bulkrax.rb#L118) field. Bulkrax requires the [source_identifier]((https://github.com/samvera-labs/bulkrax/blob/main/app/parsers/bulkrax/application_parser.rb#L279-L291)) field. The attribute representing the `source_identifier` can be added on the imported file, or we can configure bulkrax to create one on import. For now, we will add it to our CSV. I have created sample CSV's for your use during this workshop in ["5-BULKRAX/fixtures"](./fixtures/). The CSV for this exercise can be found [here](./fixtures/required-fields-only.csv) if you would like to save it. Otherwise, you can create your own.
>_NOTE: although the `source_identifier` column heading will map to the `source` attribute on the model by default, we must now explicitly state our intended `source_identifier` value. Otherwise, Bulkrax will not respect the `source` attribute as unique._

Update the `default_field_mapping` object in the app config file to include the following, then restart the server:

```ruby
'source' => { from: ['source_identifier'], source_identifier: true },
'title' => { from: ['title'] }
```
> _NOTE: I prefer to explicitly set all mappings for a given parser to cover all bases._

At the "/importers" endpoint, give your importer a name, select the Administrative Set and choose the Parser type of CSV. Once a parser type is selected, the additional applicable fields will show up. In our case, we only need to be concerned with uploading our CSV. Click the "Upload a File" radio button and then browse to find and select your file.

Press "Create and Import".

Visit http://hyku.test/sidekiq and you ought to see 1 enqueued job. If the app was started using `docker compose up web`, then we will need to manually start Sidekiq as well to process the background job.

``` bash
docker compose exec web sh
sidekiq
```

Once the `ImportWorkJob` completes, there will still be the `ScheduledRelationshipsJob`. We can enqueue it automatically since we know the work has been created. Now, go back to the Importers index page and refresh. You ought to have an importer with a status of "Completed". Click on the name of your importer and see your successfully created work entry. :tada:
From there you can click on the link to your newly created work!

How was a work created if we only listed a title and source_identifier on the CSV?
Excellent question! In your app bulkrax config file there's a `config.default_work_type` property. By default, it's set to `Hyrax.config.curation_concerns.first`. We have not updated that value, therefore our imported data was created as a GenericWork.

### [4] Import Fields Without Custom Mapping
In addition to the required fields, we are able to import a file that has other column names. Without adding any further custom mapping, Bulkrax will automatically handle column names that are the same as the attribute found on the work type. e.g., the GenericWork work type has an attribute called `creator`, so the value in a column named `creator` will map to it with no additional setup needed.

This works because bulkrax will use the [default_field_mapping](https://github.com/samvera-labs/bulkrax/blob/main/lib/bulkrax.rb#L187-L200) in order to correctly assign the imported data as the attributes on the appropriate Work.

Sample CSV [here](./fixtures/no-custom-mapping.csv)

### [5] Import a Complex CSV
Now we'll import a CSV that needs to form relationships, add a file and have custom bulkrax mappings. To begin with, let's add the following to the `Bulkrax::CsvParser` mappings in our app bulkrax config file.

``` ruby
'creator' => { from: ['creator'], split: '\|' },
'description' => { from: ['profile'] }
```
The first line says if there is a pipe ("|") character in the values underneath the "creator" column, split the value at that character. e.g., there are multiple creators.
  - We must escape the pipe so that the value only gets split on the pipe, and not split on every character. Ref: [this code](https://github.com/samvera-labs/bulkrax/blob/main/app/matchers/bulkrax/application_matcher.rb#L36-L43).
  - Another way to have multiple creators would be to use the "_#" syntax. e.g. "creator_1" and "creator_2" could be the column header names.
The second line tells bulkrax that if it encounters a column heading of "profile" on a CSV, that it should be linked to the "description" attribute on the work.

Restart the server using your preferred method.

Sample zip [here](./fixtures/complex-csv.zip).

In the CSV inside of that zip file, you'll see 3 rows. Therefore, we'll be making 3 new models. We also have 3 new column headings:
- `model`: this specifies which work type each row should wind up being
- `parents`: this is one way to establish relationships between two or more models:
  - Collection:Collection
  - Work:Work
  - Collection:Work
  - Work:Fileset
- `file`: the name of the file that should be attached to this model
  - In order for this to work, there must be a file with this name inside of the "files" folder that is a sibling to the csv referencing it.
  - ref: https://github.com/samvera-labs/bulkrax/wiki/CSV-Importer#files-location

Let's import the zip file now!

### [6] Export
Visit the "/exporters" endpoint and click "New".
- Name: whatever you'd like
- Type of Export: Metadata and Files
- Export From: All
- Export Format: CSV

Press "Create and Export".

The above options will export the metadata and files for every Collection, Work and FileSet in the current tenant in CSV format. It will use the mappings in the app bulkrax config file to create the column headers. If you do not have a mapping for a particular field, you run the risk of it not exporting.

For the amount of works we have, the export shouldn't take long. Once completed, refresh the page and you should see a dropdown underneath the "Downloadable Files" header on the Exporters index page.

If there were over 1000 items exported, there would be multiple CSV's as they split at 1000 by default. In this case, there should only be one zip file. Press the "Download" button next to the name of your zip and it will download to your computer.

Open the downloaded file and observe your data!

### [7] Round Trip
A use case for round tripping is when a user wants to update a value on one or more works that already exist in the tenant. In that case, the user would create an export with the appropriate settings, update the value(s), then import that CSV.
> _NOTE: It is crucial that the values underneath the attribute representing the  `source_identifier` are NOT changed. That value, along with the `id` of the item, is how bulkrax determines uniqueness. If you change either, duplicates will be made and/or errors will occur._

Looking at the CSV, you'll notice that the numerated headers are used. This is the default. A singular heading can be used if the mapping is updated to specifically require it.

For the moment, we don't need to change any values on the CSV. We can simply import the zip that was just exported. Afterwards, we should see no duplicates.

