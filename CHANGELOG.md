# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2023-11-03

### Added

- First version added. It deploy Hello World app as Google Cloud Run service via Terraform.
- It configure the service for internal & external load balancer traffics. 
- It creates NEG for the service and uses in the Global public loadbalancer.
