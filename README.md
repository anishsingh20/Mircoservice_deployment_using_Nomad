# Mircoservice_deployment_using_Nomad
This tutorial showcases how to use Nomad to deploy a Microservice in Python




## Introduction

The world of DevOps and container orchestration is constantly changing, and picking the right tool can make a big difference in how efficiently microservices are deployed. One tool that stands out is [HashiCorp Nomad](https://www.nomadproject.io/ ). In this guide, we'll dive into what Nomad is, the advantages it brings, and how you can deploy a simple microservice using [Nomad](https://www.nomadproject.io/ ).



## Prerequisites

Before we begin, make sure you have the following installed:

Nomad installed and nomad agent running on your system. 
Docker installed and running on your operating system.
## What is Nomad?

Nomad is a modern, lightweight workload scheduler developed by HashiCorp. It is designed to schedule and orchestrate both containerized and non-containerized workloads, including virtual machines and static binaries. Nomad provides a simple and efficient way to manage the deployment and scaling of applications across a cluster of machines. With its pluggable architecture and support for various task drivers such as Docker and Java, Nomad offers flexibility and compatibility with a wide range of technologies.

## Why Nomad?

Nomad is a standout tool for its simplicity and versatility. It is lightweight, easy to set up, and supports multiple workload types, including Docker containers, VMs, and standalone applications. Nomad's decentralized architecture allows for high availability and scalability, making it an excellent choice for deploying and managing microservices. 


### Benefits of using Nomad

Simplicity and Ease of Use: 
Nomad follows a simple and easy-to-understand design, making setting up and deploying applications quick. Its declarative syntax and minimal configuration ease the learning curve.

2. Versatility in Workload Types:
Nomad supports a variety of workload types, providing flexibility in deployment. Whether you're working with Docker containers, virtual machines, or standalone applications, Nomad can orchestrate and manage them seamlessly.

3. Scalability and High Availability:
Nomad's decentralized architecture ensures high availability and scalability. It can distribute workloads across multiple nodes, preventing a single point of failure and allowing for dynamic scaling based on demand.

4. Resource Efficiency:
Nomad is lightweight and has a small resource footprint, making it suitable for both small and large-scale deployments.

5. Integration with HashiCorp Ecosystem:
Nomad integrates seamlessly with other [HashiCorp tools](https://developer.hashicorp.com/nomad/tools ), such as Consul for service discovery and Vault for secure secret management, and much more. This integration enhances the overall security and reliability of your infrastructure.


6. Infrastructure Agnosticism:
Nomad is more agnostic about the underlying infrastructure, allowing it to run on various cloud providers, on-premises, or in hybrid environments.


Check out Nomad’s official [documentation](https://developer.hashicorp.com/nomad/docs) and it’s [Comparison guide](https://developer.hashicorp.com/nomad/intro/vs )


 


## Microservices deployment using Nomad - Implementation 


Now let's dive into the implementation of microservices deployment using Nomad. This section will walk you through the steps involved in setting up Nomad, running your first job, and scaling up your application.


### Step 1: Setting up Nomad

Once Nomad is installed, you can start Nomad in "dev mode" using the following command:

```shell

nomad agent -dev

```

You will observe an output like the one below:

```
Output:
==> No configuration files loaded
==> Starting Nomad agent...
==> Nomad agent configuration:

       Advertise Addrs: HTTP: 127.0.0.1:4646; RPC: 127.0.0.1:4647; Serf: 127.0.0.1:4648
            Bind Addrs: HTTP: [127.0.0.1:4646]; RPC: 127.0.0.1:4647; Serf: 127.0.0.1:4648
                Client: true
             Log Level: DEBUG
               Node Id: 51b0f49b-564b-5d1c-8e99-a17336c2a597
                Region: global (DC: dc1)
                Server: true
               Version: 1.6.2

==> Nomad agent started! Log data will stream in below:

    2023-12-05T18:43:58.414+0530 [INFO]  nomad.raft: initial configuration: index=1 servers="[{Suffrage:Voter ID:e707dbd2-be06-7cfc-dff0-a11714eec76f Address:127.0.0.1:4647}]"
    2023-12-05T18:43:58.415+0530 [INFO]  nomad.raft: entering follower state: follower="Node at 127.0.0.1:4647 [Follower]" leader-address= leader-id=

```


This will start the Nomad agent on your machine as the server and client components. In dev mode, Nomad runs on a single node and does not persist in any data, making it ideal for experimentation and development. 

You can access the Nomad web user interface by visiting http://localhost:4646 in your browser once the Nomad agent starts running.




### Step 2): Nomad Job Specification

Nomad jobs are defined by the Nomad job specification, also known as ***"jobspec"***. The jobspec schema is written in [HCL](https://github.com/hashicorp/hcl ).

The [job](https://developer.hashicorp.com/nomad/docs/job-specification/job ) specification is divided into smaller sections, which you can find in the navigation menu. Nomad HCL is parsed in the command line and then sent to Nomad in JSON format via the HTTP API. The general hierarchy for a job is:
job
  \_ group
  |     \_ task
  |     \_ task
  |
  \_ group
        \_ task
        \_ task


Let’s talk about each in a bit more detail: 

[task](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview#task) - Nomad uses tasks as the smallest unit of work. These tasks are executed by task drivers such as docker or exec, which allow Nomad to be flexible in the tasks it supports. Tasks specify their required task driver, configuration for the driver, constraints, and resources required.


[group](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview#group) -A group refers to a set of tasks that are executed on a single Nomad client."


[Job](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview#job) - A job is the core unit of control for Nomad and defines the application and its configurations. It can contain one or many tasks.


[job specification](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview#job-specification) - A job specification, also known as a jobspec defines the schema for Nomad jobs. This describes the type of job, the tasks and resources necessary for the job to run, job information like which clients it can run on, and more.


[allocation](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview#allocation) - An allocation is a mapping between a task group in a job and a client node. When a job is run, Nomad will choose a client capable of running it and allocate resources on the machine for the task(s) in the task group defined in the job.

The above constructs make up a Job in Nomad. 

Now that Nomad is operational, we can schedule our first job. Our initial task will involve running the ```http-echo``` Docker container. This straightforward application generates an HTML page displaying the arguments passed to the http-echo process, such as "Hello World". The process dynamically listens on a port specified by another argument.

**Note: Nomad also supports the use of dynamic port assignment, i.e you don’t need to specify a port.**


Let’s create a job file that ends with the name “microservice.nomad”. All the job files in Nomad end with ```.nomad```suffix .


```
job "http-microservice" {
  datacenters = ["dc1"]
  group "echo" {
    count = 1
    task "server" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "Hello and welcome to ${NOMAD_IP_http} running on port ${NOMAD_PORT_http}. This is my first microservice deployment using Nomad.",
        ]
      }
      resources {
        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }
}

```

In this example, we defined a job called ```http-microservice```, set the driver to use ```docker``` and pass the necessary text and port arguments to the container. As we need network access to the container to display the resulting webpage, we define the resources section to require a network with a port that Nomad chooses dynamically from the host machine to the container.
Step3):  Running the Nomad Job

We can [submit/run](https://developer.hashicorp.com/nomad/docs/commands/job/run 
) new or update existing jobs with the ```nomad job run``` command, using job files that conform to the [job specification format](https://developer.hashicorp.com/nomad/docs/job-specification ).

```shell
nomad job run microservice.nomad

```

Output:

```shell

==> 2023-12-06T13:58:25+05:30: Monitoring evaluation "bd6dd191"
    2023-12-06T13:58:25+05:30: Evaluation triggered by job "http-microservice"
    2023-12-06T13:58:25+05:30: Evaluation within deployment: "b8499a02"
    2023-12-06T13:58:25+05:30: Evaluation status changed: "pending" -> "complete"
==> 2023-12-06T13:58:25+05:30: Evaluation "bd6dd191" finished with status "complete"
==> 2023-12-06T13:58:25+05:30: Monitoring deployment "b8499a02"
  ✓ Deployment "b8499a02" successful
    
    2023-12-06T13:58:25+05:30
    ID          = b8499a02
    Job ID      = http-microservice
    Job Version = 0
    Status      = successful
    Description = Deployment completed successfully
    
    Deployed
    Task Group  Desired  Placed  Healthy  Unhealthy  Progress
    Deadline
    echo        1        1       1        0
    2023-12-06T14:08:23+05:30



```


We can alternatively check the status of a job using the command:




```shell
 nomad job status

```

Output:
```shell
ID                 Type     Priority  Status   Submit Date
http-microservice  service  50        running  2023-12-05T19:01:51+05:30

```


You can access the Nomad UI using the below command to check the Jobs and other important details of your deployment:

```shell

nomad ui <job_name>

```

```shell
nomad ui http-microservice

```



You can also visit http://127.0.0.1:8080 in your browser and you will see the http-echo webpage with the text we passed as an argument in the job file:



### Scaling up our App

One of the key benefits of using Nomad is its ability to scale your microservices based on demand. To scale up your job, simply modify the job file to increase the ```count``` parameter or use the ```nomad job scale <job> <count>``` command. 

Let’s scale our hello-world microservice:


```shell

nomad job scale http-microservice 3

```

Output:

```shell
    2023-12-05T19:28:45+05:30: Evaluation status changed: "pending" -> "complete"
==> 2023-12-05T19:28:45+05:30: Evaluation "84241aca" finished with status "complete"
==> 2023-12-05T19:28:45+05:30: Monitoring deployment "a26236c7"
  ✓ Deployment "a26236c7" successful
    
    2023-12-05T19:28:58+05:30
    ID          = a26236c7
    Job ID      = http-microservice
    Job Version = 1
    Status      = successful
    Description = Deployment completed successfully
    
    Deployed
    Task Group  Desired  Placed  Healthy  Unhealthy  Progress
    Deadline
    echo        3        3       3        0
    2023-12-05T19:38:57+05:30


```

On the Nomad UI(http://localhost:4646/ui/jobs), we can see the changes being reflected on the go:






## Some additional features and concepts you can explore in Nomad


Nomad offers a range of advanced features and concepts that can further enhance your deployment strategy:

1. Task Drivers:
Nomad supports multiple [task drivers](https://developer.hashicorp.com/nomad/docs/drivers ), allowing you to choose the best runtime environment for your applications. Explore different task drivers for various workload types.

2. Task Groups:
Organize your tasks into [groups](https://developer.hashicorp.com/nomad/docs/job-specification/group) for logical separation and resource allocation. Task groups enable you to define specific constraints and settings for different sets of tasks.

3. Update Policies:
Nomad provides flexible [update policies](https://developer.hashicorp.com/nomad/docs/job-specification/update) for controlling how your jobs are updated. Explore strategies like rolling updates to ensure zero downtime during deployments.

4. Service Discovery:
Utilize Nomad's integration with Consul for seamless [service discovery](https://www.hashicorp.com/blog/nomad-service-discovery ). This is crucial for dynamic microservices architectures where services need to locate and communicate with each other. 

## Conclusion

Congratulations! You've successfully deployed a simple microservice and explored some advanced features of Nomad. The simplicity, versatility, and integration capabilities of Nomad make it a compelling choice for DevOps engineers managing microservices at scale. Consider exploring more features and integrating Nomad into your broader infrastructure to maximize efficiency and scalability.

You can check out [Nomad’s tutorial](https://developer.hashicorp.com/tutorials/library?product=nomad ) library and its comprehensive and detailed [introduction guide](https://developer.hashicorp.com/nomad/tutorials/get-started/gs-overview 
) to gain deeper insights into using Nomad. 

Happy orchestrating with HashiCorp Nomad!

