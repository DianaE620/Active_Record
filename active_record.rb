http://guides.rubyonrails.org/active_record_basics.html
http://api.rubyonrails.org/classes/ActiveRecord/Relation.html
http://guides.rubyonrails.org/v3.2.13/migrations.html
http://guides.rubyonrails.org/v3.2.13/active_record_validations_callbacks.html

--------------- What is Active Record?

Active Record is the M in MVC - the model - which is the layer of the system responsible for representing 
business data and logic. Active Record facilitates the creation and use of business objects whose data 
requires persistent storage to a database. It is an implementation of the Active Record pattern which 
itself is a description of an Object Relational Mapping system.

--------------- Object Relational Mapping

Object-Relational Mapping, commonly referred to as its abbreviation ORM, is a technique that connects 
the rich objects of an application to tables in a relational database management system. Using ORM, 
the properties and relationships of the objects in an application can be easily stored and retrieved 
from a database without writing SQL statements directly and with less overall database access code.

--------------- Active Record as an ORM Framework

Active Record gives us several mechanisms, the most important being the ability to:

Represent models and their data.
Represent associations between these models.
Represent inheritance hierarchies through related models.
Validate models before they get persisted to the database.
Perform database operations in an object-oriented fashion.

--------------- Convention over Configuration in Active Record

The idea is that if you configure your applications in the very same way most of the time then this 
should be the default way. Thus, explicit configuration would be needed only in those cases where 
you can't follow the standard convention.

----- Naming Conventions

By default, Active Record uses some naming conventions to find out how the mapping between models 
and database tables should be created. Rails will pluralize your class names to find the respective 
database table. So, for a class Book, you should have a database table called books. The Rails 
pluralization mechanisms are very powerful, being capable to pluralize (and singularize) both regular 
and irregular words. When using class names composed of two or more words, the model class name should 
follow the Ruby conventions, using the CamelCase form, while the table name must contain the words 
separated by underscores. Examples:

Database Table - Plural with underscores separating words (e.g., book_clubs).
Model Class - Singular with the first letter of each word capitalized (e.g., BookClub).

Model / Class   Table / Schema
  Article           articles
  LineItem          line_items
  Deer              deers
  Mouse             mice
  Person            people

----- Schema Conventions

Foreign keys - These fields should be named following the pattern singularized_table_name_id 
(e.g., item_id, order_id). These are the fields that Active Record will look for when you create 
associations between your models.

Primary keys - By default, Active Record will use an integer column named id as the table's primary key. 
When using Active Record Migrations to create your tables, this column will be automatically created.

There are also some optional column names that will add additional features to Active Record instances:

- created_at - Automatically gets set to the current date and time when the record is first created.
- updated_at - Automatically gets set to the current date and time whenever the record is updated.
- lock_version - Adds optimistic locking to a model.
- type - Specifies that the model uses Single Table Inheritance.
- (association_name)_type - Stores the type for polymorphic associations.
- (table_name)_count - Used to cache the number of belonging objects on associations. 
  For example, a comments_count column in a Articles class that has many instances of 
  Comment will cache the number of existent comments for each article.

----- Creating Active Record Models

It is very easy to create Active Record models. All you have to do is to subclass the 
  ActiveRecord::Base class

  class Product < ActiveRecord::Base
  end

This will create a Product model, mapped to a products table at the database. By doing this you'll 
also have the ability to map the columns of each row in that table with the attributes of the 
instances of your model. Suppose that the products table was created using an SQL sentence like:

CREATE TABLE products (
   id int(11) NOT NULL auto_increment,
   name varchar(255),
   PRIMARY KEY  (id)
);

Following the table schema above, you would be able to write code like the following:

p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"


----- Overriding the Naming Conventions
You can easily override the default conventions.

You can use the ActiveRecord::Base.table_name= method to specify the table name that should be used:

class Product < ActiveRecord::Base
  self.table_name = "my_products"
end

If you do so, you will have to define manually the class name that is hosting the fixtures 
(my_products.yml) using the set_fixture_class method in your test definition:

class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  ...
end

It's also possible to override the column that should be used as the table's primary key using the 
ActiveRecord::Base.primary_key= method:

class Product < ActiveRecord::Base
  self.primary_key = "product_id"
end


--------- CRUD: Reading and Writing Data

CRUD is an acronym for the four verbs we use to operate on data: Create, Read, Update and Delete. 
Active Record automatically creates methods to allow an application to read and manipulate data 
stored within its tables.

-- Create

Active Record objects can be created from a hash, a block or have their attributes manually set after 
creation. The new method will return a new object while create will return the object and save it to 
the database.

For example, given a model User with attributes of name and occupation, the create method call will 
create and save a new record into the database:

user = User.create(name: "David", occupation: "Code Artist")

Using the new method, an object can be instantiated without being saved:

user = User.new
user.name = "David"
user.occupation = "Code Artist"

A call to user.save will commit the record to the database.

Finally, if a block is provided, both create and new will yield the new object to that block for initialization:

user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end

-- Read

Active Record provides a rich API for accessing data within a database. Below are a few examples of 
different data access methods provided by Active Record.

# return a collection with all users
users = User.all

# return the first user
user = User.first

# return the first user named David
david = User.find_by(name: 'David')

# find all users named David who are Code Artists and sort by created_at in reverse chronological order
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)

-- Update

Once an Active Record object has been retrieved, its attributes can be modified and it can be saved 
to the database.

user = User.find_by(name: 'David')
user.name = 'Dave'
user.save

A shorthand for this is to use a hash mapping attribute names to the desired value, like so:

user = User.find_by(name: 'David')
user.update(name: 'Dave')

This is most useful when updating several attributes at once. If, on the other hand, you'd like to 
update several records in bulk, you may find the update_all class method useful:

User.update_all "max_login_attempts = 3, must_change_password = 'true'"

This is most useful when updating several attributes at once. If, on the other hand, you'd like to update several records in bulk, you may find the update_all class method useful:

User.update_all "max_login_attempts = 3, must_change_password = 'true'

-- Update

Likewise, once retrieved an Active Record object can be destroyed which removes it from the database.

user = User.find_by(name: 'David')
user.destroy

--------- Validations

Active Record allows you to validate the state of a model before it gets written into the database. 
There are several methods that you can use to check your models and validate that an attribute 
value is not empty, is unique and not already in the database, follows a specific format and many more.

Validation is a very important issue to consider when persisting to the database, so the methods save 
and update take it into account when running: they return false when validation fails and they didn't 
actually perform any operation on the database. All of these have a bang counterpart (that is, save! 
  and update!), which are stricter in that they raise the exception ActiveRecord::RecordInvalid if 
validation fails. A quick example to illustrate:

class User < ActiveRecord::Base
  validates :name, presence: true
end
 
user = User.new
user.save  # => false
user.save! # => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank


http://guides.rubyonrails.org/active_record_validations.html

--------- Callbacks

Active Record callbacks allow you to attach code to certain events in the life-cycle of your models. 
This enables you to add behavior to your models by transparently executing code when those events occur, 
like when you create a new record, update it, destroy it and so on.

--------- Migrations

Rails provides a domain-specific language for managing a database schema called migrations. Migrations 
are stored in files which are executed against any database that Active Record supports using rake. 
Here's a migration that creates a table:

class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.integer :publisher_id
      t.string :publisher_type
      t.boolean :single_issue
 
      t.timestamps null: false
    end
    add_index :publications, :publication_type_id
  end
end

Rails keeps track of which files have been committed to the database and provides rollback features. 
To actually create the table, you'd run rake db:migrate and to roll it back, rake db:rollback.

--------------- Migrations

Las migraciones son archivos que sirven para crear tablas y modificarlas en la base de datos.

Migrations are a convenient way for you to alter your database in a structured and organized manner. 
You could edit fragments of SQL by hand but you would then be responsible for telling other developers 
that they need to go and run them. You’d also have to keep track of which changes need to be run against 
the production machines next time you deploy.

Active Record tracks which migrations have already been run so all you have to do is update your source 
and run rake db:migrate. Active Record will work out which migrations should be run. It will also 
update your db/schema.rb file to match the structure of your database.

Migrations also allow you to describe these transformations using Ruby. The great thing about this 
is that (like most of Active Record’s functionality) it is database independent: you don’t need to 
worry about the precise syntax of CREATE TABLE any more than you worry about variations on 
SELECT * (you can drop down to raw SQL for database specific features). For example you could 
use SQLite3 in development, but MySQL in production.


Before we dive into the details of a migration, here are a few examples of the sorts of things you can do:

class CreateProducts < ActiveRecord::Migration
  def up
    create_table :products do |t|
      t.string :name
      t.text :description
 
      t.timestamps
    end
  end
 
  def down
    drop_table :products
  end
end

This migration adds a table called products with a string column called name and a text column called description. 
A primary key column called id will also be added, however since this is the default we do not need to ask for this. 
The timestamp columns created_at and updated_at which Active Record populates automatically will also be added. 
Reversing this migration is as simple as dropping the table.


--- Migrations are not limited to changing the schema. You can also use them to fix bad data in the database or populate 
    new fields:

class AddReceiveNewsletterToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.boolean :receive_newsletter, :default => false
    end
    User.update_all ["receive_newsletter = ?", true]
  end
 
  def down
    remove_column :users, :receive_newsletter
  end
end


This migration adds a receive_newsletter column to the users table. We want it to default to false for new users, but existing 
users are considered to have already opted in, so we use the User model to set the flag to true for existing users.


- Makes migrations smarter by providing a new change method. This method is preferred for writing constructive migrations 
  (adding columns or tables). The migration knows how to migrate your database and reverse it when the migration is rolled 
  back without the need to write a separate down method.

class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
 
      t.timestamps
    end
  end
end

-------------- Migrations are Classes

A migration is a subclass of ActiveRecord::Migration that implements two methods: up (perform the required transformations) and down (revert them).

Active Record provides methods that perform common data definition tasks in a database independent way (you’ll read about them in detail later):

add_column
add_index
change_column
change_table
create_table
drop_table
remove_column
remove_index
rename_column

-------------- Changing Migrations

Occasionally you will make a mistake when writing a migration. If you have already run the migration then you cannot just edit 
the migration and run the migration again: Rails thinks it has already run the migration and so will do nothing when you run 
rake db:migrate. 

- You must rollback the migration (for example with rake db:rollback), edit your migration and then run rake 
db:migrate to run the corrected version.

In general editing existing migrations is not a good idea: you will be creating extra work for yourself and your co-workers and 
cause major headaches if the existing version of the migration has already been run on production machines. Instead, you should 
write a new migration that performs the changes you require. Editing a freshly generated migration that has not yet been 
committed to source control (or, more generally, which has not been propagated beyond your development machine) is relatively 
harmless.

-------------- Supported Types

Active Record supports the following database column types:

:binary
:boolean
:date
:datetime
:decimal
:float
:integer
:primary_key
:string
:text
:time
:timestamp

These will be mapped onto an appropriate underlying database type. For example, with MySQL the type :string is mapped to VARCHAR(255).
 You can create columns of types not supported by Active Record when using the non-sexy syntax, for example

create_table :products do |t|
  t.column :name, 'polygon', :null => false
end

-------------- Creating a Model

The model and scaffold generators will create migrations appropriate for adding a new model. This migration will already contain instructions for creating the relevant table. If you tell Rails what columns you want, then statements for adding these columns will also be created. For example, running

$ rails generate model Product name:string description:text
will create a migration that looks like this

class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
 
      t.timestamps
    end
  end
end




