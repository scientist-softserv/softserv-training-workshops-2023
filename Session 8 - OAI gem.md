![image](https://user-images.githubusercontent.com/10081604/265060617-1a3cb12c-ee6f-494e-9ed6-610135e377d2.png)

November 1, 2023. 11AM to 5PM ET

Welcome! In this session, we will be exploring the [blacklight_oai_provider plugin](https://github.com/projectblacklight/blacklight_oai_provider) which uses the [ruby-oai](https://github.com/code4lib/ruby-oai) gem to set up and configure OAI

## Contents
- [Basic Instructions](#basic-instructions)
- [Goals](#oai-goals)
- [Concepts](#oai-concepts)
- [Exercises](#oai-exercises)
- [OAI Documentation](#community-oai-documentation)

## Basic Instructions
See [Running the stack](https://github.com/scientist-softserv/softserv-training-workshops-2023#running-the-stack) for setup directions if necessary. It is assumed that you have a running dev environment prior to beginning these exercises. 

For your actual work, please checkout and make a branch off of main, or continue on a branch from a previous workshop. If working from a previous session branch, be sure to pull and merge in `main` to bring in any updates.

You can use this branch as a working example, to check your progress as you work through the exercises.

## OAI Goals
* Develop understanding of OAI core concepts
* Understand how to install and utilize the OAI gem

## OAI Concepts
### Introduction
[OAI-PMH (Open Archives Initiative
Protocol for Metadata Harvesting)](https://www.openarchives.org/pmh/) is a mechanism for repository interoperability. Data Providers expose structured metadata, which can be harvested via requests. The OAI-PMH specification describes the 6 verbs which are used to make the data requests, the XML schema for the responses, and the underlying data model. A valid request MUST include one of the six verbs.

### OAI Verbs
1. Identify - `verb=Identify` gives basic information about the OAI 
2. ListRecords - `verb=ListRecords&metadataPrefix=oai_dc` provides a paginated list of records in the repository, with a `resumption token` to access the next or prior pages. Requires a **metadata prefix**. To use the resumption token, add `&resumptionToken={token}`
3. ListSets - `verb=ListSets` lists all sets which are defined. A specific set can be included to limit the response of a ListRecords request.
4. ListMetadataFormats - `verb=ListMetadataFormats` lists all metadata formats which are defined. 
5. ListIdentifiers - `verb=ListIdentifiers&metadataPrefix=oai_dc` provides a paginated list of identifiers in the repository. Requires a **metadata prefix**.
6. GetRecord - `verb=GetRecord&metadataPrefix=oai_dc&identifier={your identifier}` used to retrieve an individual metadata record from a repository. Requires an **identifier** and a **metadata prefix**.

### OAI Harvester in Hyku

Bulkrax has the ability to consume an OAI feed from another source and import data into your Hyku repository. Mappings must be configured in `config/initializers/bulkrax.rb`, similarly to how you configured the csv importer in Session 5.

```
  # You may have removed OAI parser from your app during session 5. If you are building on prior work, you will need to undo this configuration change.
  config.parsers -= [
    { name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields" }
  ]

  # You will need to add field mappings from your external OAI feed to your Hyku app.
  config.field_mappings["Bulkrax::OaiDcParser"] = default_field_mapping.merge({
    # add or remove custom mappings for this parser here
  })
```

### OAI Provider in Hyku
The OAI gem allows us to provide the data from the Hyku repository. It is included in Hyku with a basic configuration. Bulkrax is an example of a harvester, providing a way to harvest from a repository's OAI feed. 

OAI is included in hyku, via gems [blacklight_oai_provider](https://github.com/projectblacklight/blacklight_oai_provider) and [ruby-oai](https://github.com/code4lib/ruby-oai), with the default configuration implementing the `oai_dc` metadataPrefix. The install generator made the following Hyku app changes:

**CatalogController**
- include BlacklightOaiProvider::Controller
- config.oai = { }
  - defaults set in super admin console

**SolrDocument**
- include BlacklightOaiProvider::SolrDocument
- field_semantics.merge!( )

**Routes**
- concern :oai_provider, BlacklightOaiProvider::Routes.new
- under resource :catalog add concerns :oai_provider

The default url for OAI requests in Hyku is `{tenant url}/catalog/oai?` followed by the verb and other required arguments. This can be seen on a hyku app, without any additional configuration by using `verb=Identify`. An xsxlt document is used to display the results. Right-click and view page source to see the unformatted xml.

**Some simple customization points:**

- The number of items returned for a request can be modified in `catalog_controller.rb`
- New sets can be defined in `catalog_controller.rb` for any facetable terms. The pre-set configuration only defines sets for Admin Sets.
- Term mappings for the `oai_dc` metadataPrefix can be customized in `solr_document.rb`. Available terms for oai_dc are: `contributor`, `coverage`, `creator`, `date`, `description`, `format`, `identifier`, `language`, `publisher`, `relation`, `rights`, `source`, `subject`, `title`, `type`
- The repository name used in the `catalog_controller` config is the tenant's name. 
- The `record prefix`, `admin email`, and `sample id` values used in the `catalog_controller` config can be configured individually by tenant in either the app's superadmin dashboard or on the tenant's admin dashboard.
- Hyku implements two metadataPrefixes (oai_dc and oai_hyku): `oai_dc` implements only the standard dc terms, and `oai_hyku` contains extended terms to map as desired.

### Adding a new metadata format
Implementing a new metadataPrefix requires several oai gem overrides & customizations:

- Add `lib/oai/provider/metadata_format/xxxxxx.rb`, where `xxxxxx` is the new format being defined. Normally in `initialize` the array of terms is set as `@fields =`.
- Add (or update) `lib/oai/provider/model_decorator.rb` to define `map_xxxxxx`, the mapping from Hyku terms to the terms specified in @fields, for the new metadataPrefix.
- Update `application.rb` to require & load the new oai files:
```
# OAI additions
Dir.glob(File.join(File.dirname(__FILE__), "../lib/oai/**/*.rb")).sort.each do |c|
  Rails.configuration.cache_classes ? require(c) : load(c)
end
```
- Add (or update) `lib/oai/provider/response/list_metadata_formats_decorator.rb` to include `prefix == xxxxxx`

### Implementing a mods metadataPrefix
Implementing `mods` metadataPrefix varies somewhat from the above steps, as the oai gems do not define the xml so that needs to be added.

Differences from the above-described steps include:

- Do not define @fields in `mods.rb`. Instead, define a method encode which will replace the field definitions as well as the mappings normally done in `model_decorator.rb`:
```
# Override to strip namespace and header out
def encode(model, record)
  record.to_oai_mods
end
```
- Add `app/model/concerns/mods_solr_document.rb` which defines `to_oai_mods` and returns the mods xml document for the object.

## OAI Exercises
1. Access your oai_dc feed using `{tenant url}/catalog/oai?verb=Identify`
   - Familiarize yourself with the UI and the resulting URL options
   - Test accessing all of the verbs
   - View the xml version of your results
   - Access the next page of your feed by using the resumption token
2. Customize your setup
   - Change the name of the `oai:hyku` prefix (this applies to ALL metadata formats)
   - Change your admin email
   - Change the number of items shown per request
3. Add a thumbnail url to your `oai_hyku` feed
4. Implement a new set
   - By default, AdminSets are OAI sets
   - Any faceted solr term can become a set
5. Bonus: Implement a new XML metadata format
   - See [Adding a new metadata format](#adding-a-new-metadata-format)
6. Bonus: Implement a new MODS metadata format
   - See [Implementing a mods metadataPrefix](#implementing-a-mods-metadataprefix)

### Exercise Solutions

<details>
<summary>Exercise 1</summary>
 
 (coming soon)

</details>

<details>
<summary>Exercise 2</summary>
 
 (coming soon)

</details>

<details>
<summary>Exercise 3</summary>
 
 (coming soon)

</details>

<details>
<summary>Exercise 4</summary>

 (coming soon)

</details>

<details>
<summary>Exercise 5</summary>

 (coming soon)

</details>

<details>
<summary>Exercise 6</summary>

 (coming soon)

</details>

## Community OAI Documentation

The OAI-PMH working group has been pulling together documention, which is now located on the [Samvera Wiki](https://samvera.atlassian.net/wiki/spaces/samvera/pages/2251751437/OAI-PMH+Documentation).