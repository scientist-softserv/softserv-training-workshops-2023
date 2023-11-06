<a id="orge7bf6d3"></a>

# Best Practices

<details open><summary>Table of Contents</summary>

-   [Goals](#orgc63c022)
-   [Topics](#orgc21bdd7)
    -   [Inline Documentation (yardoc)](#org77e90c2)
        -   [Solargraph](#orgb42e3c5)
        -   [Exercises](#orgc45346a)
    -   [Code Coverage (simplecov)](#org5e4d640)
        -   [Exercises](#org40a7dcc)
    -   [Responsible Overrides](#org6100838)
        -   [Class Methods versus Instance Methods](#orgc7047d5)
        -   [Documentation Tangent](#org8786707)
        -   [Objects are Classes and Classes are Objects](#org0afb85c)
        -   [Revisiting Class Methods and Instance Methods](#org62478e4)
        -   [Always Open For Antics](#org9868298)
        -   [Include a Module](#org019d323)
        -   [ActiveSupport::Concern](#orge1779ff)
        -   [Prepend](#org93926e2)
        -   [Method Location](#orgf720564)
        -   [Where Are You Super…Man?](#orga03bc5b)
            -   [Exercise](#org5b3a530)
        -   [Class Warfare](#orgb5b9a5b)
        -   [What A $LOAD\_PATH!](#org4a227ff)
            -   [Exercise](#orgca98ff6)
        -   [Back to the Decorator Pattern](#org7ed3399)
            -   [Let’s Read Some Code](#org960522e)
            -   [Explaining the Decorating](#org255aa9d)
            -   [Exercise](#org3722bf2)
        -   [Class Attribute](#orgc2c583a)
            -   [Exercise](#orgf9641fe)
        -   [Room for a View](#org488a468)
            -   [Gotchas](#orgdf08594)
    -   [OrderAlready…Already](#orgb28d464)
        -   [Exercise](#orge9e70e2)

</details>


First, know that there are no best practices.  There is only gaining a better understanding of how to cope with the complexities of software development.


<a id="orgc63c022"></a>

## Goals

-   Learn more about the inline documentation.
-   Develop a deeper understanding of the [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) and <abbr title="Ruby on Rails">Rails</abbr> environment.
-   Practice writing tests as an exploratory tool.
-   Quickly implement an oft-requested feature; namely preserve the input order of the `creator` field.


<a id="orgc21bdd7"></a>

## Topics

We’ll cover four high-level topics:

-   Inline Documentation
-   Code Coverage
-   Responsible Overrides
-   Order Already

The majority of this time will be in `Responsible Overrides`.  Mixed through-out are exercises, which are to be worked on independently.


<a id="org77e90c2"></a>

### Inline Documentation (yardoc)

<details open>

Folks in [Samvera](https://samvera.org/) use Yardoc for writing their inline documentation.

-   Generate the documentation for a project by running `yard doc`.
-   View the local document by opening `./doc/index.hml`.

You can “merge documentation” by running it across different projects:

```bash
cd ~/git
yard doc \
    softserv-training-workshops-2023/app/**/*.rb \
    softserv-training-workshops-2023/lib/**/*.rb \
    hyrax/lib/**/*.rb \
    hyrax/app/**/*.rb
```

The above will create the `~/git/doc` directory and you can open the `~/git/doc/index.html` file in your browser.

I have found the [Tags Overview](https://rubydoc.info/gems/yard/file/docs/Tags.md#List_of_Available_Tags) to be most helpful when writing documentation.


<a id="orgb42e3c5"></a>

#### Solargraph

[Solargraph](https://solargraph.org/) is a Language Server that read’s the code’s Yardoc.  You can then use <abbr title="Language Server Protocol">LSP</abbr> tooling within your editor to connect to [Solargraph](https://solargraph.org/) and get things like:

-   informed code completion
-   documentation
-   jump to definition


<a id="orgc45346a"></a>

#### Exercises

-   Generate the documentation for `softserv-training-workshops-2023`.
-   `gem install yard`; this need not be done in the docker container (assuming you have Ruby installed outside of docker).
-   Review the documentation.

-   Fix and improve the documentation for `CreateAccount#initialize`.  When you ran `yard doc` it likely issued the following warning: ``@param tag has unknown parameter name: in file `app/services/create_account.rb' near line 9``
-   Review the `CreateAccount` documentation
-   Fix the warning
-   Document the `users` parameter for `CreateAccount#initialize`
-   Re-run `yard doc` and review the changes.
-   See [session-9-exercise-fix-yardoc-warning branch](https://github.com/scientist-softserv/softserv-training-workshops-2023/tree/session-9-exercise-fix-yardoc-warning) for a solution.

-   Clone Hyrax into the same parent directory as the `softserv-training-workshops-2023` project.
-   Ensure that you clone checks out the correct tagged version specified by `softserv-training-workshops-2023`.
-   Generate the combined documentation for both projects.

-   Get language server support going:    
-   Add [Solargraph](https://solargraph.org/) as a development gem to the project.
-   Enable <abbr title="Language Server Protocol">LSP</abbr> for your text editor; using [Solargraph](https://solargraph.org/) as the language server.
-   See [session-9-exercise-add-solargraph branch](https://github.com/scientist-softserv/softserv-training-workshops-2023/tree/session-9-exercise-add-solargraph) for a solution.

Related Blog Post: <https://takeonrules.com/2023/07/15/refactoring-to-understand-a-code-base/>

</details>

<a id="org5e4d640"></a>

### Code Coverage (simplecov)

<details open>

Many of the [Samvera](https://samvera.org/) projects use the [simplecov](https://github.com/simplecov-ruby/simplecov) gem to generate the test suite’s code coverage.  Similar to Yardoc, [simplecov](https://github.com/simplecov-ruby/simplecov) writes the coverage output to the project’s `./coverage` directory.

You can review the output by opening `./coverage/index.html`; this assumes you’ve run specs on your project.


<a id="org40a7dcc"></a>

#### Exercises

-   Review the `./coverage/index.html` file.
-   Find some code that is not called during a test, then write a test that would call that code.

</details>

<a id="org6100838"></a>

### Responsible Overrides

Please stop me to clarify.  This can get confusing quickly, but should help elucidate the subject.

<details open>

The “Decorator” pattern is a mix of guidelines for maintainability as well as situational how-to.  At <abbr title="Software Services by Scientist.com">SoftServ</abbr> we have a [Decorators playbook article](https://playbook-staging.notch8.com/en/dev/ruby/decorators-and-class-eval).

Why call it “Decorator”?  Spree, a long-standing Rails project, favored the phrase “Decorator” over “Override”.

To understand how to effectively override, we must delve into the Ruby object model.

-   Class methods compared to Instance Methods
-   Modules versus Classes
-   Objects are Classes and Classes are Objects
-   Prepend, Include, and Extend


<a id="orgc7047d5"></a>

#### Class Methods versus Instance Methods

A class method is typically defined as `def self.my_class_method`.  An instance method is defined as `def my_instance_method`.

There is a gotcha.  The following will create a class method.

```ruby
self << class
  def my_class_method; end
end
```


<a id="org8786707"></a>

#### Documentation Tangent

The documentation notation for instance methods uses a `#` sign.  For example, `String#start_with?` indicates "`String`'s instance method `start_with?`".

The notation for class methods is either `.` (<abbr title="example given">e.g.</abbr> "period") or `::` (<abbr title="example given">e.g.</abbr> "double colon").  I favor `.` notation.  For example, `String.new` indicates "`String`'s class method `new`".


<a id="org0afb85c"></a>

#### Objects are Classes and Classes are Objects

A little Zen koan.  But important to consider; let’s review a few basic strings.

```nil
irb(main):001:0> hello = "hello"
=> "hello"
irb(main):002:0> hello.class
=> String
irb(main):003:0> hello.singleton_class
=> #<Class:#<String:0x00000001004a41a0>>
irb(main):004:0> world = "world"
=> "world"
irb(main):005:0> world.class == hello.class
=> true
irb(main):006:0> world.singleton_class == hello.singleton_class
=> false
irb(main):007:0> world.singleton_class
=> #<Class:#<String:0x0000000104db47c8>>
irb(main):008:0> String.object_id
=> 25880
irb(main):009:0> hello.object_id
=> 147080
irb(main):010:0> world.object_id
=> 159120
irb(main):011:0> hello.singleton_class.object_id
=> 183560
irb(main):012:0> world.singleton_class.object_id
=> 175340
```

Why is this important?  Because you can add methods to one class without adding it to another; and that goes for singleton classes.


<a id="org62478e4"></a>

#### Revisiting Class Methods and Instance Methods

-   **`String.instance_methods`:** returns an array of methods that all `String` instances will have.
-   **`String.methods`:** returns an array of methods that `String` has (<abbr title="example given">e.g.</abbr> class methods).
-   **`String.new.methods`:** returns the array of methods that this instance of `String` has.
-   **`String.new.instance_methods`:** raises `NoMethodError`; we’ve instantiated a `String` and an instance has `#methods` not `#instance_methods`.
-   **String.new.singleton\_class.methods:** typically these will be `String.methods`.
-   **String.new.singleton\_class.instance\_methods:** typically these will be `String.instance_methods`.

Why is this important?  Because it can be confusing.

And by drawing attention to it and talking about it, we can begin to remove the confusion and better understand Ruby’s object model and understand the reasons behind the various approaches for overrides.

Fundamentally we want to override `String.methods` and/or `String.instance_methods`; and we do that via modules.


<a id="org9868298"></a>

#### Always Open For Antics

If you’ve spent time programming, you may have heard that code should be closed to modification but open to extension.  [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) eschews that, instead cleaving closer to [Lisp](https://en.wikipedia.org/wiki/Lisp_(programming_language)) and Smalltalk.

[Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language))’s object model defaults that all objects as open for modification; and remember all classes are objects.  This is part of the reason that the `include` function (among other things) works.  It’s also why [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) is a choice language for writing <abbr title="Domain-Specific Language">DSLs</abbr>.


<a id="org019d323"></a>

#### Include a Module

If you’ve spent any time in Ruby code you’ve seen something like the following:

```ruby
class User
  include Hyrax::User
end
```

The above code does the following:  We add all of the `Hyrax::User.instance_methods` to `User.instance_methods`.  That is, when we instantiate a `User` object, the methods from `Hyrax::User` will be available to that instantiation.

By default, none of the `Hyrax::User.methods` are added to the `User.methods` array.  That is, none of `Hyrax::User`'s class methods are added as class methods on `User`.  That, however, is only part of the story.


<a id="orge1779ff"></a>

#### ActiveSupport::Concern

Below is something you might see in the `Hyrax::User` module.

```ruby
module Hyrax
  module User
    extend ActiveSupport::Concern

    included do
      has_many :email_addresses, dependent: :destroy
    end

    class_methods do
      def hyrax_user_class_method
      end
    end

    def hyrax_user_instance_method
    end
  end
end
```

**Sidebar:** When you use `extend ActiveSupport::Concern` you are adding the `ActiveSupport::Concern.instance_methods` to the the receiver’s `methods`.  Said another way, we’re adding the instance methods of a module to another class’s class methods.

Let’s walk through what’s going on:

-   **`extend ActiveSupport::Concern`:** This <abbr title="Ruby on Rails">Rails</abbr> module provides some “syntactic sugar” to provide a consistent interface for modifying an object’s class and instance methods.  [Let’s look at the documentation](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html).

-   **`included do`:** When the `Hyrax::User` is included in the `User` class (via `include Hyrax::User`), we will evaluate the block in the context of `User` class.  (<abbr title="example given">e.g.</abbr> the `included do` block is the behaves like calling `User.has_many :email_addresses, dependent: :destroy` (that is the ActiveRecord syntax for declaring a relationship on a model).

-   **class\_methods do:** When we include the `Hyrax::User` we add the methods declared to the `User.methods`.  (<abbr title="example given">e.g.</abbr> the methods in the `class_methods do` block become class methods on `User`).

-   **`def hyrax_user_class_method`:** This method is added to `User.instance_methods`.


<a id="org93926e2"></a>

#### Prepend

You may also have seen something like `User.prepend Some::CoolThing`.  From the [Module#prepend\_features documentation](https://rubydoc.info/stdlib/core/Module:prepend_features):

> When this module is prepended in another, Ruby calls `#prepend_features` in this module, passing it the receiving module in *mod*. Ruby’s default implementation is to overlay the constants, methods, and module variables of this module to *mod* if this module has not already been added to *mod* or one of its ancestors. See also Module#prepend.

We’ll need to contrast that somewhat obtuse bit of documentation with [Module#append\_features documentation](https://rubydoc.info/stdlib/core/Module#append_features-instance_method) (which is called when `User.include Some::CoolThing`:

> When this module is included in another, Ruby calls `#append_features` in this module, passing it the receiving module in *mod*. Ruby’s default implementation is to add the constants, methods, and module variables of this module to *mod* if this module has not already been added to mod or one of its ancestors. See also Module#include.

The operative word for `Module#prepend` is “overlay” and for `Module#include` it is “add”.

Put another way, `include` is courteous and lines up as it happens and is added to the ancestor chain.  And `prepend` waits until the `include` line forms, shows up late, and budges in front of everyone in the ancestor chain.

Or use `prepend` when you want to nudge/push something towards your desired behavior; such as when you want to “Decorate.”


<a id="orgf720564"></a>

#### Method Location

I’m assuming folks are familiar with the `super` construct.

Let’s look at the `GenericWorkIndexer#generate_solr_document` instance method.

We can use the following to find the location:

```bash
docker compose exec web rails runner "puts GenericWorkIndexer.instance_method(:generate_solr_document).source_location"
```

*Note:* `Method#source_location` returns an array.  The first element being the absolute path to the file.  And the second element being the starting line of the method.

Now let’s look to the `Method#source`:

```bash
docker compose exec web rails runner "puts GenericWorkIndexer.instance_method(:generate_solr_document).source"
```

Notice that we have `super`.

With `$LOAD_PATH` considerations, it can be helpful to assert where the method is defined.


<a id="orga03bc5b"></a>

#### Where Are You Super…Man?

Since [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) 2.5, we’ve had access to `Method#super_method`.  We can ask a `Method` object what it’s super `Method` object is.

```bash
docker compose exec web rails runner "puts GenericWorkIndexer.instance_method(:generate_solr_document).super_method.source_location"
```


<a id="org5b3a530"></a>

##### Exercise

Write a test that asserts the source file location of `GenericWorkIndexer#generate_solr_document`.  Then write a test that asserts the source file location of the `super` method of `GenericWorkIndexer#generate_solr_document`.

*Hint:* All <abbr title="Ruby on Rails">Rails</abbr> engines have a `root` method that you can use to join paths (<abbr title="example given">e.g.</abbr>  `Hyrax::Engine.root.join("path/to/file/within/engine.rb")`).  This is far more durable than hard-coding the absolute path.

The [session-9-exercise-super-interesting branch](https://github.com/scientist-softserv/softserv-training-workshops-2023/tree/session-9-exercise-super-interesting) has a solution.


<a id="orgb5b9a5b"></a>

#### Class Warfare

Remember, [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) is open for modification.  We re-open classes all of the time.  But it can be precarious to directly open the class.

For example, consider the following:

```ruby
class Dog
  def speak
    "Bark"
  end
end

puts Dog.new.speak
> "Bark"

class Dog
  # I want a yappy dog!
  def speak
    "#{super} #{super} #{super}"
  end
end

puts Dog.new.speak
> dog.rb:10:in `speak': super: no superclass method `speak' for #<Dog:0x0000000104368710> (NoMethodError)
        from dog.rb:14:in `<main>'
```

When we directly re-open the class, we might lose context of `super`.  However if we use modules, we preserve our `super` ancestry.

```ruby
class Dog
  def speak
    "Bark"
  end
end

puts Dog.new.speak
> "Bark"

# We re-open the class and include the Yappy module
class Dog
  module Yappy
    def speak
      "#{super} #{super} #{super}"
    end
  end
  include Yappy
end

puts Dog.new.speak
> "Bark Bark Bark"
```


<a id="org4a227ff"></a>

#### What A $LOAD\_PATH!

<abbr title="Ruby on Rails">Rails</abbr>’ boot sequence is complicated.  But it does use the [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)) `$LOAD_PATH` constant.  In a <abbr title="Ruby on Rails">Rails</abbr> application, each gem adds itself to the `$LOAD_PATH`; typically in order in which they are declared/referenced.

Typically in <abbr title="Ruby on Rails">Rails</abbr> when you reference a constant (e.g. `Hyrax::User`) it will loop through the `$LOAD_PATH` and in essence append `hyrax/user.rb`, check if the file is there, and if so use that.  In this way you can mask another object in your application.

I said in “essence append” because Rails and it’s engines each add their own “app/models”, “app/controllers”, etc. to the `$LOAD_PATH`.


<a id="orgca98ff6"></a>

##### Exercise

In the Hyku instance for the workshop; open up the <abbr title="Ruby on Rails">Rails</abbr> console:

1.  Find all of the load paths for the Hyrax gem.
2.  Review the first 10 paths in the `$LOAD_PATH`.


<a id="org7ed3399"></a>

#### Back to the Decorator Pattern

At <abbr title="Software Services by Scientist.com">SoftServ</abbr> and [Samvera](https://samvera.org/) we’ve adopted a “Decorator” pattern.  Often times for a specific application instance we need to amend/replace logic in a [Samvera](https://samvera.org/) gem.

We could work to generalize that behavior in the gem (and bring that generalization forward as well as test with other implementations) or we can apply a local decorator.


<a id="org960522e"></a>

##### Let’s Read Some Code

Here is the [Hyrax::ManifestBuilderServiceDecorator](https://github.com/scientist-softserv/softserv-training-workshops-2023/blob/55e938eb5538abe00fc1e38aa9b919a0b273409b/app/services/hyrax/manifest_builder_service_decorator.rb#L1-L26); a decorator in Hyku.

```ruby
# frozen_string_literal: true

module Hyrax
  module ManifestBuilderServiceDecorator
    private

      ##
      # @return [Hash<Array>] the Hash to be used by "label" to change `&amp;`  to `&`
      # @see #loof
      def sanitize_value(text)
        return loof(text) unless text.is_a?(Hash)
        text[text.keys.first] = text.values.flatten.map { |value| loof(value) }
        text
      end

      ##
      # @return [String] the String that gets unescaped since Loofah is too aggressive for example
      #   it changes to `&` to `&amp;` which will be displayed in the Universal Viewer and manifest
      # @see #sanitize_value
      def loof(text)
        CGI.unescapeHTML(Loofah.fragment(text.to_s).scrub!(:prune).to_s)
      end
  end
end

Hyrax::ManifestBuilderService.prepend(Hyrax::ManifestBuilderServiceDecorator)
```

Note the pattern:

-   Declare a decorator module with the desired methods.
-   Prepend the decorator module to the target class.

To understand it’s impact, let’s go look at [what the above code is decorating](https://github.com/samvera/hyrax/blob/b334e186e77691d7da8ed59ff27f091be1c2a700/app/services/hyrax/manifest_builder_service.rb).


<a id="org255aa9d"></a>

##### Explaining the Decorating

I chose the above code because it looks like it would be easy to re-introduce into Hyrax.  But we’d need to consider:

-   [Hyku](https://github.com/samvera/hyku) often tracks to earlier versions of Hyrax; which means we’d need to submit a <abbr title="Pull Request">PR</abbr> and back-port that change.
-   The impact of the change on upstream Hyrax.

Fair warning: I’ve often seen decorators missing their tests.  I’d love for that not to be the case.


<a id="org3722bf2"></a>

##### Exercise

In <abbr title="Software Services by Scientist.com">SoftServ</abbr>’s [Overrides with Decorators and Class Eval](https://playbook-staging.notch8.com/en/dev/ruby/decorators-and-class-eval) playbook article we go over the how of decoration.

Read up on the [Initialization Events of Rails](https://guides.rubyonrails.org/configuring.html#initialization-events).

Review the `to_prepare` block in the workshop’s [./config/application.rb](https://github.com/scientist-softserv/softserv-training-workshops-2023/blob/55e938eb5538abe00fc1e38aa9b919a0b273409b/config/application.rb#L35-L40) file.

Find all of the Ruby files in this workshop that are overrides.

Find all of the files in the project that have “OVERRIDE” as part of a comment.


<a id="orgc2c583a"></a>

#### Class Attribute

API Documentation :: <https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute>

Throughout [Samvera](https://samvera.org/) and other <abbr title="Ruby on Rails">Rails</abbr> applications, developers make use of the `Class.class_attribute` method.  It’s used for things like:

-   Dependency injection
-   Configuration management

It’s two primary benefits are:

-   Gracefully handles inheritance (<abbr title="example given">e.g.</abbr> subclasses that override a class attribute do not alter the parent nor siblings)
-   Exposes instance accessors, which enables dependency injection (something that is especially helpful during testing)

Here’s some code for the [Hyrax::Dashboard::CollectionsController](https://github.com/scientist-softserv/softserv-training-workshops-2023/blob/601577c58519e488dbfbb93c198bb9d1abdc7980/app/controllers/hyrax/dashboard/collections_controller.rb#L34-L46):

```ruby
class_attribute :presenter_class,
                :form_class,
                :single_item_search_builder_class,
                :membership_service_class

self.presenter_class = Hyrax::CollectionPresenter

self.form_class = Hyrax::Forms::CollectionForm

# The search builder to find the collection
self.single_item_search_builder_class = SingleCollectionSearchBuilder
# The search builder to find the collections' members
self.membership_service_class = Collections::CollectionMemberSearchService

```

Hyrax in particular uses this to declare a collaborating concept (e.g. `presenter_class`) as well as the default collaborator (e.g. `Hyrax::CollectionPresenter`).  In this way, if downstream implementers want to change the presentation logic, they could do the following:

```ruby
Hyrax::Dashboard::CollectionsController.presenter_class = MyCollectionPresenter
```


<a id="orgf9641fe"></a>

##### Exercise

-   Clone the Hyrax repository
-   Checkout the `hyrax-v3.5.0` tag
-   Find all of the `class_attribute` declarations
-   How many are there?
-   Pick one or two and read how this `class_attribute` is used in that code


<a id="org488a468"></a>

#### Room for a View

One practical example of class attribute in action is `ApplicationController.view_paths`.

Much like the `$LOAD_PATH`, <abbr title="Ruby on Rails">Rails</abbr> has a concept of a `view_paths`.  When Rails renders a view (<abbr title="example given">e.g.</abbr> a layout, template or partial) it looks up that view in the `view_paths`.  The first found match is what we render.  This typically favors application views over engine views.

This functionality is part of <abbr title="Ruby on Rails">Rails</abbr> public <abbr title="Application Programming Interface">API</abbr>.  And [Hyku](https://github.com/samvera/hyku) leverages this functionality for theming.


<a id="orgdf08594"></a>

##### Gotchas

Unlike the “Decorator” pattern, it can be hard to track upstream changes.  If you create a view in your Hyku application that takes precedence over a Hyrax view; and that Hyrax view changes, you may not know that the underlying change happened.

We recommend that when you override a view, you add a comment in the code that mentions the override, the version impacted, and why the change (e.g. “OVERRIDE Hyrax 3.5.0 to add additional CSS class”).

</details>

<a id="orgb28d464"></a>

### OrderAlready…Already

<details open>

[Fedora Commons](https://en.wikipedia.org/wiki/Fedora_Commons) stores data as <abbr title="Resource Description Framework">RDF</abbr>.  Compared to a relational database, ordering triples with the same predicate is not a simple matter.  This requires linked lists and aggregation objects. *And is gross when you’ve worked with <abbr title="Structured Query Language">SQL</abbr>.*

An often requested feature is to preserve the input order for authors/creators.  To do this in <abbr title="Resource Description Framework">RDF</abbr> is gross and painful.

We created the [OrderAlready gem](https://github.com/samvera-labs/order_already).  It is a data hack to introduce an ordering prefix to each value on the triple.


<a id="orge9e70e2"></a>

#### Exercise

Add the [OrderAlready gem](https://github.com/samvera-labs/order_already) to your project and order the creators property of:

-   `GenericWork`
-   `Image`

Write a test for these changes.  I recommend creating `spec/models/generic_work_spec.rb` and `spec/models/image_spec.rb`.

See the [session-9-exercise-add-solargraph branch](https://github.com/scientist-softserv/softserv-training-workshops-2023/pull/new/session-9-exercise-order-already) for an approach.

</details>
