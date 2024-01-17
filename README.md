# terraform-module-template
A standard template for creating reusable modules under the Lucidus Solutions organization. Delete the contents of this README.md file to create room for module content. 

## Initializing a New Module Repository
Run the following command:
<pre><code>gh repo create lucidus-solutions/{repoName} --public -p lucidus-solutions/terraform-module-template -c</code></pre>

## Creating new modules
Modules should...
- always be self-contained in their own repositories
- not have any additional files than what is established in this repository
- follow exact naming conventions for variables and locals as referred in this template
- declare the compatible version of terraform and various providers as necessary

## Usage
<pre><code>module "this" {
  source = "github.com/lucidus-solutions/terraform-aws-{module}

  name        =
  env         =
  program     =

}</code></pre>