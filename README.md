# Nomad

**Create cloud portable Elixir and Phoenix apps. Write once, use everywhere!**

## What is the Nomad Project?
Nomad is an Open-Source API for Elixir that enables developer to use the most popular cloud providers interchangeabily at will without having to change any of their code. Nomad provides generic API's for cloud services (mainly Virtual Machines, Storage, SQL and JSON datastores). These API's offer the most useful features and functionalities that are common across the same kind of service between cloud providers. They are meant to be simple and user friendly. This enables applications to be portable and allows the migration of applications from one provider to the next.

Moreso Nomad offers Mix Tasks for automatic management of cloud resources for your application. Need a SQL database in the Cloud for your application? Create it and automatically configure your app to use the one you just created. Want to host your Phoenix app in the Cloud? Launch a Virtual Machine through Nomad Mix Tasks and let it automatically deploy a production release of your app in said VM.

This project is my subject for my Master's Thesis but once it's delivered it will be a pure Open Source application.

**Disclaimer: Nomad is under heavy development and is prone to changes**

### What are the use cases for Nomad?
The main goal of the Nomad project is to defeat Cloud Vendor Lock-in in the Elixir ecosystem. With the rise in popularity of cloud services Elixir users should not be restricted to one provider and should be able to make the most out of Cloud Computing. Some of the identified use cases are the following (but there are many more):

  1. You're using S3 storage for a Phoenix application but a few months later Google has better pricing? Just let Nomad automatically copy your whole S3 bucket to a Google Storage bucket and relaunch the app with Google configurations.
  2. Recently got a new userbase in a remote region? Launch a new Virtual Machine with your application in the closest available region.
  3. Need a powerful SQL database but you're not really knowledgeable in Cloud related affairs? Just use Nomad's user friendly API and it will get done in a jiffy!

### How is this achieved?
Nomad takes a lot of inspiration from [Ecto](https://github.com/elixir-lang/ecto) and uses adapters in a similar fashion. First and foremost the needed API functions are identified based on what the cloud providers' APIs have to offer and on what are the most recurring use cases and used functionalities. From this a general Elixir Behaviour is defined. These Behaviours must be implemented by each provider's adapter. 

Each adapter will implement the APIs for each cloud service (Virtual Machines, SQL, Storage and Datastore). Upon starting up an application a simple config in the desired environment config is needed - mainly cloud account credentials and a key to identify the chosen provider.

Finally through macros and metaprogramming, the adapters logic will be generated for the Nomad main modules (VirtualMachines, SQL, Storage and Datastore modules).

### Installation

  1. Add nomad to your list of dependencies in mix.exs:

          def deps do
              [{:nomad, "~> 0.5.1"}]
          end
        or
          def deps do 
              [{:nomad, github: "sashaafm/nomad" }]
            end

  2. Ensure nomad is started before your application:

          def application do
            [applications: [:nomad]]
          end

### Configuration
#### General
For every cloud provider you will need to add to your desired environment the following:

    config :nomad, 
      cloud_provider: <provider_atom>
      
#### Amazon Web Services
To use Amazon Web Services the following configurations are needed:

    config :nomad,
      cloud_provider: :aws
      
Then pass your AWS Access Key ID and AWS Secret Access Key as System variables when launching the application like so:

    AWS_ACCESS_KEY_ID=<aws_access_key_id> AWS_SECRET_ACCESS_KEY=<secret_access_key>
    
#### Google Cloud Platform
To use Google Cloud Platofrm te following configurations are needed:

    config :nomad,
      cloud_provider: :gcl
    
    config :goth, 
      json: "config/creds.json" |> Path.expand |> File.read!
      
Where 'creds.json' is the JSON file with your account credentials that you may download from your Google Cloud Console. Alternatively you may name the file whatever you want as long as you change the config accordingly.

### API Specifications and Usage Examples
#### Storage

**Specification Docs**
[Online Documentation](https://hexdocs.pm/nomad/Nomad.Storage.html) - Docs still under development

**Examples**


  1. List available storages

         Nomad.Storage.list_storages
         #=> ["bucket_1", "bucket_2"]
  
  2. List files inside a storage
  
         Nomad.Storage.list_items "bucket_1"
         # => [".gitignore", "/random/archive/Director-free.zip",
         "/new_dir/other_dir/some_file.txt", "README.md", "architecture.png",
         "examples/examples.desktop", "storage_API"]    
        
  3. Create a storage
    
         Nomad.Storage.create_storage "bucket_name", "region_name", "bucket_class"
         # => :ok

  4. Combine API functions

         Nomad.Storage.list_storages |> Enum.map(fn storage -> {storage, Nomad.Storage.get_storage_region(storage)} end)
         [{"bucket_1", "EUROPE-WEST1"}, {"bucket_2", "US"}]

  
#### SQL
**Specification Docs**
[Online Documentation](https://hexdocs.pm/nomad/Nomad.SQL.html) - Docs still under development

**Examples**

#### Virtual Machines
**Under development**

#### Datastore
** Under development**

### Mix Tasks

#### Available Mix Tasks


