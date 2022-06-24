# Dynamic Terraform Startup Scripts on Compute Instances

## Overview

This solution shows how to insert Terraform defined variables into a startup script that runs on a Google Compute Instance in Qwiklabs. Additionally, since this solution uses variables created in Terraform, each variable can be set as an output and surfaced dynamically in the lab guide. 

This guide will walk you through the necessary steps to incorporate this into your lab.


### Use cases

The following are some use cases for this solution:
* Adding any Terraform defined variable/local value to a startup script that runs on a GCE Instance
* Create a list of regions, have Terraform randomly select and assign the variable, then have the GCE Instance run a `gcloud` command to delete itself using the variable (instead of hard coding it)
* Dynamically insert lab usernames into a startup script that runs on the GCE Instance (for example, to remove IAM roles)
* Assign specific tasks/resources to provision based off of a Terraform variable (for example, assign a randomized bug number from a list of bugs that a student has to fix)
* Anything else you can think of!

#### Folder Hierarchy

The example is based on the following hierarchy:

```output
├── instructions
│   ├── en.md
│   └── img
├── QL_OWNER
├── qwiklabs.yaml
└── terraform
    ├── scripts
    │   └── startup_script.tftpl
    ├── main.tf
    ├── outputs.tf
    ├── runtime.yaml
    └── variables.tf
```


### Instructions


#### Download the files

To start, run the following command in your lab folder to add the example Terraform code to your project:

```
curl  -L https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/install.sh | bash
```

#### Create your dynamic variables

In this section, you will create a randomized number in Terraform and put that into a startup script. 

1. In your `main.tf` file, add the following resource:

```
resource "random_integer" "random_int" {
  min = 1
  max = 100
}
```

In this example, we are creating a random integer resource with a minimum value of 1 and a maximum value of 100.

2. Create a **local** value to save the result. 

In Terraform, a local value assigns a *name* to an *expression*, so you can use the name multiple times within a module instead of repeating the expression.

For the local value, you can use the following code block to define it. Notice the `.result` following the resource name. This is how you grab the *value* of the random integer resource. 

In the `main.tf` file, add the following:

```
locals {
  my_random_integer = random_integer.random_int.result
}
```

3. Once you have defined your local value, you can insert it into the `metadata_startup_script` argument of the `google_compute_instance` resource.

For example:

```
resource "google_compute_instance" "startup-vm" {
  ...
  ...
  metadata_startup_script = <your script file and variables>
  ...
}
```

4. Once you have your `google_compute_instance` resource defined, you can use the [templatefile](https://www.terraform.io/language/functions/templatefile) function to read the startup script file at the given path and render its content as a template using a supplied set of template variables.

Since your `startup_script.tftpl` file is in the `scripts/` directory, you would reference the the file and the variable in the following way:

```
metadata_startup_script = templatefile("scripts/startup_script.tftpl", {random_integer = "${local.my_random_integer}"})
```

Additionally, you could also define a startup script with multiple variables:

```
metadata_startup_script = templatefile("scripts/startup_script.tftpl", { random_integer = "${local.my_random_integer}", gcp_region = "${var.gcp_region}"})
```

**Note** the file type `.tftpl`. This allows Terraform to render the variables in the file before running it on the VM. Simply change the `.sh` file type of your bash script to `.tftpl` and Terraform will handle the rest. Your bash script contents will remain the same. If you cloned the files from the repo, the startup script is already in the `.tftpl` format.

Now, you can reference the variable in the bash script as you would any other Terraform variable. The following example is the way you would generically put in a variable into the startup script:

```output
#!/bin/bash
...
export variable=${variable}
```

6. To add your `random_integer` variable, you would put the following into your `scripts/startup_script.tftpl` file:

```
#!/bin/bash
...
export random_integer=${random_integer}
```

And that's it!

For reference, your entire `google_compute_instance` Terraform resource should now resemble the following:

```
resource "google_compute_instance" "startup-vm" {
  description = "Runs a dynamic script"
  name         = "startup-vm"
  machine_type = "f1-micro"
  zone         = local.random_zone
  tags         = ["http-server"]
  metadata_startup_script = templatefile("scripts/startup_script.tftpl", {random_integer = "${local.my_random_integer}"})
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}
```

7. Optionally, you could also add the local value as an output so you can surface it in the lab guide.

In the `outputs.tf` file, add the following output:

```
output "random_integer" {
  value = "${local.my_random_integer}"
}
```


## Reference code

The following are some reference code examples you can use in your configuration files:


Template `google_compute_instance` resource with rendered startup script:

```
resource "google_compute_instance" "startup-vm" {
  description = "Runs a dynamic script"
  name         = "startup-vm"
  machine_type = "f1-micro"
  zone         = local.random_zone
  tags         = ["http-server"]
  metadata_startup_script = templatefile("scripts/startup_script.tftpl", {variable = "${var.variable_name}"})
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}
```





