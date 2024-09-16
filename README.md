# Deployment and CI/CD Documentation for WordPress Project for WIS DevOps Test

## Introduction

This document outlines the deployment process for a WordPress project using a CI/CD pipeline with GitHub Actions, including backup automation, health checks, and server configuration best practices. The project utilizes AWS resources and ensures efficient deployment and management of the WordPress application.

## 1. Project Setup

### EC2 Instance

- **Instance Creation**: An EC2 instance was created using AWS CDK (Python) to host the WordPress application.
- **Security Groups**: Ports 80 (HTTP) and 22 (SSH) were configured to allow web traffic and remote access.

### S3 Bucket

- **Purpose**: An S3 bucket was set up to store backups of the MySQL database.
- **Configuration**: The bucket was configured to be accessible by the WordPress application for backup purposes.

### WordPress Installation

- **Method**: WordPress was installed on the EC2 instance using a user data script. This installation includes the default WordPress setup, which ensures that the application is ready for further customization.

## 2. CI/CD Pipeline Configuration

### Overview

The CI/CD pipeline is managed using GitHub Actions. This automation tool helps streamline the deployment process by triggering actions on code changes in master branch.

### Key Steps

- **Build Theme Assets**: The pipeline compiles the theme assets (SCSS and JS files). This step ensures that any changes to the theme are properly built before deployment.
- **Deploy to Server**: The updated files are transferred to the EC2 instance. This is accomplished using `rsync`, which synchronizes the local files with the server.
- **Check Response Code**: After deployment, a health check is performed to verify that the WordPress site is accessible and returns a status code of 200. This step ensures that the site is live and operational after updates.

### GitHub Actions Workflow

A GitHub Actions workflow is set up to automate the build, deployment, and testing processes. It includes:

- **Checkout Code**: Retrieves the latest code from the repository.
- **Build Theme Assets**: Compiles SCSS and JS files for the WordPress theme.
- **Deploy to Server**: Uses `rsync` to deploy the updated files to the EC2 instance.
- **Check WordPress Site Response Code**: Performs a health check to ensure the site is responding with a status code of 200.

## 3. Backup Automation

### Backup Process

The backup process involves regularly saving copies of the MySQL database to the S3 bucket. This ensures that data can be recovered in case of any issues or data loss. Backups are automated using a cron job on the EC2 instance, which runs at a scheduled time (e.g., daily).
bash
```
mysqldump --no-tablespaces -h 52.31.56.237 -u wordpressuser -pwordpresspassword wordpress > backup_file.sql
```

This command connects to the MySQL server at 52.31.56.237, uses the wordpressuser account, and dumps the wordpress database to a file named backup_file.sql.
Benefits

    Data Safety: Regular backups protect against data loss.
    Automated Management: Automation reduces manual intervention and ensures consistent backup schedules.

### Benefits

- **Data Safety**: Regular backups protect against data loss.
- **Automated Management**: Automation reduces manual intervention and ensures consistent backup schedules.

## 4. Server Configuration Best Practices

### Apache Configuration

If Apache is used as the web server, here are some best practices for configuration:

#### Virtual Hosts

- **Setup Virtual Hosts**: Configure virtual hosts to manage multiple domains or applications on the same server. This includes setting up directives for each domain, specifying the document root, and configuring access controls.

#### SSL Configuration

- **Obtain SSL Certificates**: Use tools like Certbot to obtain and configure SSL certificates for secure HTTPS connections.
- **Configure SSL**: Update the Apache configuration to include SSL directives, ensuring that HTTPS is enabled for the WordPress site.

#### Security and Performance

- **Security**: Implement security best practices, such as restricting access to sensitive directories and ensuring that file permissions are correctly set.
- **Performance**: Optimize Apache settings for better performance, including configuring caching and compression.

## 5. Documentation and Improvement Summary

### GitHub Repository

- **Repository**: The GitHub repository containing the CI/CD pipeline configuration, backup scripts, and other relevant files can be found here.

### Decisions and Challenges

- **CI/CD Setup**: Integrated automated deployments to ensure that updates are deployed smoothly and efficiently.
- **Backup Automation**: Set up regular backups to an S3 bucket to safeguard data.
- **Health Checks**: Implemented response code checks to confirm the operational status of the WordPress site after deployment.

### Improvements

- **Automation**: The automation of deployment and backups enhances operational efficiency and reduces manual errors.
- **Testing**: Health checks provide assurance that the WordPress site is functioning correctly after updates.

## Conclusion

This setup provides a robust solution for deploying and managing a WordPress application. By leveraging CI/CD pipelines, automated backups, and best practices for server configuration, the deployment process is streamlined, reliable, and efficient.
