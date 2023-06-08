# Dare[IT](https://www.dareit.io/challenges/cloud)`_challenge` 
**Cloud + Platform Engineer** 
<br><br>
> This project is the culmination of 9 weeks of work as part of the DareIT challenge and getting to know the cloud, and an opportunity to further develop and learn more functionalities offered by GCP.
> 
> *long story short*: this project is about how to deploy simple static website on GCP 
<br>

**[`CLICK HERE`](http://34.132.17.249/) to see the results 🚀**

<br>


## Table of Contents
* [About the task](#about-the-task-📝)
* [Technologies Used](#technologies-used-⚙️)
* [Steps of the task](#steps-of-the-task-👩‍)
* [Project Status](#project-status) 
* [Room for Improvement](#room-for-improvement-⏳)
* [Contact](#contact-☎️) 

<br>

## About the task 📝

**Brief:**

You have been asked to create a website. As a proof of concept, it will be sufficient that you demonstrate a website that displays text (e.g. Lorem Ipsum https://en.wikipedia.org/wiki/Lorem_ipsum) and an image on a single home page.
You can create your own application but can also use open-source or community software, such as WordPress (https://wordpress.org).
You can use one of the below depending on the complexity of the solution you want to create:
- static website in GCS
- single VM
- AppEngine
- two VMs behind a Load Balancer
- Kubernetes cluster (GKE)
This proof of concept is to demonstrate the technical feasibility of hosting, managing, and scaling the platform and is not about content.

**Requirements:**
1. Deliver the tooling to set up an application that displays a web page with Lorem Ipsum text and an image
2. Provide source code for creating the stack in a publicly available repository e.g. Github (https://github.com)
3. Provide basic setup documentation to run the application
4. All resources should be deployed using Terraform
5. Automate the deployment of your application using CI/CD
<br>

> **Bonus:**
> 1. Provide and document a mechanism for scaling the service and delivering the content to a larger audience
> 2. Demonstrate that you have considered how a real-world solution will be hosted and scaled.
> 3. Explain your choices.
> 
> **Another bonus:**
> 
> - Create Cloud Function that lists all VPCs and Subnets in the project and saves the data in a file that is stored in a bucket OR saves the data in the database (you can choose the database as well as the format in which you want to save the data).
> - *Requirements:*
> Provide source code for the function and any other code in a publicly available repository e.g. Github (https://github.com)

<br>

## Technologies Used ⚙️

> To deploy my static website I decided to choose Kubernetes Cluster - I don't think it made sense to use such an advanced tool, but I did it for educational purposes :) 
- GCP
- Terraform
- Kubernetes cluster
- Docker
- CI/CD

<br>

## Steps of the project 👩‍💻 

**1. Preparation of the work environment**

- creating GCP account
> Initially I worked on the old account, where I performed challenge tasks, but after the free version expired, I decided to move with all my "possessions" from the Github repository to the new GCP account - I started by re-preparing the project and replacing the secrets in github actions - doesn't sound complicated :) but once again you could see how important the order in the documentation and the appropriate names of resources, accounts, projects, etc. are - the best practice seems to be to keep such information in one place, because then making corrections to the code takes much less time :)
- creating new project
> and beacuse of that I spend a lot of time trying to connect my github repository to the new GCP project... IDs were very similar 🙈
- creating new service account and generating keys in json to communicate with GiHub actions
> according to the task 7. of our challenge
- creating bucket to hold state file
- installing needed API:
  - *Kubernetes Engine API*
  - *Artifact Registry API*

**2. Prepare GitHub repository**
- create and `clone` to my computer
- create folder with `static_website`
> I thought that, as part of this task, I could deploy [my web application](https://github.com/m-n-zuk/ibd_maternity) written in Django... but I miscalculated 🙈 knowledge in the field of GCP needs to settle in my head definitely :) but I will come back to this for sure!
- and start thinking what should be next...

**3. Terraform files**
- create `provider.tf`, `main.tf` (very similar as in task 7.)
- create `backend.tf` with resources like:
  - `google_container_cluster`
  - `google_artifact_registry_repository`


**4. Workflows**
- create `terraform.yml` (very similar as in task 7.)
> I decided to add this lines, to build  infrastructure again only when we made changes in .tf files:
>  ```yaml
>  on:
>    push:
>      paths:
>        - "**.tf"
>      branches:
>      - main
>  ```
- create `google.yml`
> After many hours of research and testing various non-working solutions I decided to use a template from Github: <br> `Actions`/`New workflow`/`Build and Deploy to GKE`... and of course (at the beggining) it doesn't work too 🤡 But using this, I was finally on right way to complete my task :) templates are good things :)
  - in this workflow are many new steps like: *Build the Docker image*, *Push the Docker image to Google Artifact Registry* or *Deploy the Docker image to the GKE cluster* which we can see in `google.yml` file.
> veeery complicated step (compared to create a bucket) for a beginner in the Cloud :) a lot of new elements and related configuration issues

**5. Load Balancer**

- choose *load balancer* to host and scale my website:
  ```yaml
  kubectl expose deployment $DEPLOYMENT_NAME --name="$DEPLOYMENT_NAME-service" --type=LoadBalancer --port 80 --target-port 80
  ```
- reasons for my decision:
  - `High Availability` Load balancers distribute incoming traffic across multiple instances of your website, ensuring that if one instance fails or becomes overwhelmed, the traffic is automatically routed to healthy instances.
  - `Scalability` Load balancers can easily handle increased traffic and allow you to scale your website horizontally by adding more instances. As the demand for your website grows, load balancers automatically distribute traffic evenly among the instances, ensuring optimal performance and responsiveness.
  - `Traffic Management` Load balancers can perform advanced traffic management techniques, such as session affinity, content-based routing, and URL-based routing. These features allow you to direct traffic to specific instances or versions of your website based on various criteria, enhancing the user experience and enabling A/B testing or gradual feature rollouts.

**6. Cloud Function**

- create `bucket` which will storage data about VPCs and Subnets
- create `Cloud Function`:
  - we need to enable the following `APIs` to use Cloud Functions:
    - *Cloud Build API*
    - *Cloud Functions API*
    - *Cloud Logging API*
    - *Cloud Pub/Sub API*
  - make sure, that we have installed *Google Cloud Storage* client libraries and *Google Cloud Compute*: <br>
    `pip install --upgrade google-cloud-storage google-cloud-compute`
  - we have to add *Cloud Functions Invoker* permission for *allUsers* in order to enter the URL  
  - trigger: HTTP (when we enter the [URL](https://us-central1-dareit-cloud-challenge-387017.cloudfunctions.net/list_vpc_and_subnets), the function will start)
  - code in Python:
  
    **`main.py`**
    ```python
    import json
    from google.cloud import storage
    from google.cloud import compute_v1


    def list_vpc_and_subnets(request):

      request_json = request.get_json()

      if request.args and 'message' in request.args:
        return request.args.get('message')

      elif request_json and 'message' in request_json:
          return request_json['message']

      else:

        project_id = "dareit-cloud-challenge-387017"
        bucket_name = "vpcs_subnets"
        file_name = "vpc_and_subnets"
        region = "us-central1"

        # Compute Engine client initialization
        compute_client = compute_v1.NetworksClient()

        # VPC list download
        vpc_list = compute_client.list(project=project_id)

        # creating a list of VPCs and subnets
        vpc_subnets = []
        for vpc in vpc_list:
          vpc_name = vpc.name
          subnets = compute_v1.SubnetworksClient().list(project=project_id, region=region)
          subnets_list = [subnet.name for subnet in subnets]
          vpc_subnets.append({
            'VPC': vpc_name,
            'Subnets': subnets_list
          })
    
        # saving data to a JSON file
        data_in_json = json.dumps(vpc_subnets)

        # Storage client initialization
        storage_client = storage.Client()

        # saving data to a file in the Storage Bucket
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        blob.upload_from_string(data_in_json)

        return f"The data has been saved to the file [{file_name}] in the bucket [{bucket_name}]: <br>{vpc_subnets}"
    ```

    **`requirements.txt`**
    ```
    google.cloud.storage==2.9.0
    google.cloud.compute==1.11.0
    ```
  <br>
>**...this task using CloudShell:**

>VPC:  **`gcloud compute networks list`**
   
>   ```
>   NAME: default
>   SUBNET_MODE: AUTO
>   BGP_ROUTING_MODE: REGIONAL
>   IPV4_RANGE: 
>   GATEWAY_IPV4: 
>   ```
>Subnetworks: **`gcloud compute networks subnets list --network=default --format="table[box](name,region,ipCidrRange)"`** 
>(I added `--format` because the list was very long)
  
   ```
   NAME: default
   REGION: us-central1
   RANGE: 10.128.0.0/20

   NAME: default
   REGION: europe-west1
   RANGE: 10.132.0.0/20

   NAME: default
   REGION: us-west1
   RANGE: 10.138.0.0/20

   NAME: default
   REGION: asia-east1
   RANGE: 10.140.0.0/20

   NAME: default
   REGION: us-east1
   RANGE: 10.142.0.0/20

   NAME: default
   REGION: asia-northeast1
   RANGE: 10.146.0.0/20

   NAME: default
   REGION: asia-southeast1
   RANGE: 10.148.0.0/20

   NAME: default
   REGION: us-east4
   RANGE: 10.150.0.0/20

   NAME: default
   REGION: australia-southeast1
   RANGE: 10.152.0.0/20

   NAME: default
   REGION: europe-west2
   RANGE: 10.154.0.0/20

   NAME: default
   REGION: europe-west3
   RANGE: 10.156.0.0/20

   NAME: default
   REGION: southamerica-east1
   RANGE: 10.158.0.0/20
 
   NAME: default
   REGION: asia-south1
   RANGE: 10.160.0.0/20

   NAME: default
   REGION: northamerica-northeast1
   RANGE: 10.162.0.0/20

   NAME: default
   REGION: europe-west4
   RANGE: 10.164.0.0/20

   NAME: default
   REGION: europe-north1
   RANGE: 10.166.0.0/20

   NAME: default
   REGION: us-west2
   RANGE: 10.168.0.0/20

   NAME: default
   REGION: asia-east2
   RANGE: 10.170.0.0/20

   NAME: default
   REGION: europe-west6
   RANGE: 10.172.0.0/20

   NAME: default
   REGION: asia-northeast2
   RANGE: 10.174.0.0/20

   NAME: default
   REGION: asia-northeast3
   RANGE: 10.178.0.0/20

   NAME: default
   REGION: us-west3
   RANGE: 10.180.0.0/20

   NAME: default
   REGION: us-west4
   RANGE: 10.182.0.0/20

   NAME: default
   REGION: asia-southeast2
   RANGE: 10.184.0.0/20

   NAME: default
   REGION: europe-central2
   RANGE: 10.186.0.0/20

   NAME: default
   REGION: northamerica-northeast2
   RANGE: 10.188.0.0/20

   NAME: default
   REGION: asia-south2
   RANGE: 10.190.0.0/20

   NAME: default
   REGION: australia-southeast2
   RANGE: 10.192.0.0/20

   NAME: default
   REGION: southamerica-west1
   RANGE: 10.194.0.0/20

   NAME: default
   REGION: us-east7
   RANGE: 10.196.0.0/20

   NAME: default
   REGION: europe-west8
   RANGE: 10.198.0.0/20

   NAME: default
   REGION: europe-west9
   RANGE: 10.200.0.0/20

   NAME: default
   REGION: us-east5
   RANGE: 10.202.0.0/20

   NAME: default
   REGION: europe-southwest1
   RANGE: 10.204.0.0/20

   NAME: default
   REGION: us-south1
   RANGE: 10.206.0.0/20

   NAME: default
   REGION: me-west1
   RANGE: 10.208.0.0/20

   NAME: default
   REGION: europe-west12
   RANGE: 10.210.0.0/20

   NAME: default
   REGION: me-central1
   RANGE: 10.212.0.0/20 
   ```


<br>

## Project Status ⏳

Project is: _in progress_

<br>

## Room for Improvement 🛠️

To do:
- consider divide my workflow
> when we change something in `website` folder - create new image and replace only, but when we change something more, connecting with deployment - whole deployment process will start again
- static IP for my website
- 'cleaning' in .yml files

<br>

## Contact ☎️
Created by [Magdalena Żuk](https://www.linkedin.com/in/m-n-zuk/) - feel free to contact me!
