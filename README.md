# Dockerized Statamic

This project provides a dockerized version of the popular CMS [Statamic](https://statamic.com/). It allows you to easily run Statamic in a Docker container.

## Prerequisites

Before using this project, ensure that you have the following:

- Docker installed on your machine

## Usage

To run Statamic using this Docker image, use the following command:

```bash
docker run -d --name statamic -p 80:80 -e DOMAIN=test.example.com adamkdean/statamic
```

Replace `test.example.com` with your desired domain.

## Configuration

The Docker image requires the following environment variable:

- `DOMAIN`: The domain name to be used for the Statamic instance. This is a required variable.

## Dockerfile

The [Dockerfile](Dockerfile) sets up an Ubuntu-based environment, installs the necessary packages, and configures Nginx and PHP-FPM to run Statamic.

## Work in Progress

Please note that this project is currently a work in progress. Additional features and improvements may be added in the future.

## License

This project is open-source.
