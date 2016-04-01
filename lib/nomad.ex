defmodule Nomad do
  
  @moduledoc """
  Nomad is a tool for cloud abstraction and cloud portability for
  Elixir and Phoenix applications. 

  It serves as a middle layer between client application and the 
  cloud provider, providing portability for both Amazon Web Services 
  and Google Cloud Platform. A common API is used for the equivalent services
  of each cloud platform.

  Nomad is modular since it only provides an interface with the available
  callbacks. The actual cloud API clients are attached as dependencies, 
  enabling developers to build new adapters for other cloud providers 
  with services that fit into Nomad's interfaces.

  A deployment Mix task is offered for easy deployment and migration of 
  applications between remote hosts intra or inter-cloud. 

  The most popular cloud services are also available:
    Amazon                       |   Google
    Simple Storage Service (S3)  |   Cloud Storage
    Elastic Compute Cloud (EC2)  |   Compute Engine 
    Relational Database (RDS)    |   Cloud SQL
  """
end
