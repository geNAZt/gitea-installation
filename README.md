# Automatic AWS installation for gitea

Goal 
===
Installation of a scalable gitea instance with managed postgres and monitoring. Current installation will take place in AWS and this repo contains all stacks needed
for creation of a EKS and postgres instance.

Configuration
===
If needed the nodetype can be changed in cluster.yaml to anything supported by `eksctl`. Current default are t3.small which can be used with x86 based container images.

To install you need to create a hosted zone with a valid domain first. The installation will attempt to generate lets encrypt certificates and routing entries in the given 
zone. The zone ID of that needs to be configured in the `cluster.yaml`. If thats not done all systems relying on DNS will get IAM errors. The zone ID also needs to be changed 
in `flux/cert-manager/cert-manager-issuer.yaml` otherwise lets encrypt will not validate our certificate challenges. Also the email field should be changed to be unique per 
domain.

The gitea instance also needs one config value. It needs the host under which it should be reachable. This can be configured in `flux/gitea/gitea-helmRelease.yaml`

Needed tooling
===
CLI Tools:
- aws
- kubernetes
- bash
- jq
- psql

Good to know
===
All resources will be spanned across 3 AZs so they are fault tolerant by default. For the database, although its spanned over 3 AZs is per default not failsafe. This has 
been done due to cost reasons (since this is only a demo project) and can be changed by setting the environment flag to pre-prod or prod.

Database passwords will be generated the secret manager in AWS. Due to a limitation of the default gitea chart there is no way to use a secret thus we need to hardcode
it inside its deployment. When the database has been created the script will get the password and automatically inject it into the gitea installation.

The installation will throw out a SSH public key after EKS installation. When a GITHUB_TOKEN has been set it will automatically try to add it to the profile. If not
ensure that the SSH key will be added to the account pulling changes, otherwise the sync marker from flux will not persist and the cluster won't install stuff.

You need to have a SSH key on your machine. The public part will be used to configure the worker nodes so one could access them if needed.

How do i install it now?
===
Select correct AWS profile
Ensure that the Route53 hosted zone is setup
Run `./install.sh`