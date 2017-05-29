# Docker image for GA4GH reference implementation server

Federated databases consist in using local resources for hosting data instead of submitting to centralized data servers ([reference](http://science.sciencemag.org/content/352/6291/1278)).
This concept facilitates sharing genomic data with restricted access to sensitive information such as individuals’ information.
It also avoids legal issues associated to data protection.
Hosting data locally leads to difficulties in data integration from different databases because each provider may implement its own non-standard interface for publishing data.
The [Global Alliance for Genomics and Health (GA4GH)](http://genomicsandhealth.org/) was formed to help accelerate the potential of genomic medicine to advance human health.
The [GA4GH Data Working Group](http://genomicsandhealth.org/node/12684) developed data model schemas and application program interfaces (APIs) for standardized genomics data exchange.
This Docker image provides the [GA4GH reference implementation server](https://github.com/ga4gh/ga4gh-server/) through Apache 2 web server exposing TCP port 80.

Run Docker container.
It will automatically pull the Docker image from [DockerHub](https://hub.docker.com/r/welliton/).

``` bash
docker container run --rm --name ga4gh-server -d -p 80:80 welliton/ga4gh-server:0.3.6
```

Explaining the command line:
`docker container run` is the base command (same as `docker run`).
`--rm` tells Docker to remove the container (not the image) after stopped.
`--name ga4gh-example` gives a name to the container (optional).
Giving a name to the container simplify management (inspect and stop container).
`-d` runs container in backgroud.
Remove this parameter to see messages of Apache 2 daemon.
`-p 80:80` makes a bridge between TCP port 80 of the container and the host.
`welliton/ga4gh-server:0.3.6` the name of the images.
This image does not have `latest` tag.
It provides a tag for each release of the GA4GH reference server. 
The image version (0.3.6) is based on [release version](https://github.com/ga4gh/ga4gh-server/releases) of the GA4GH reference server.

The GA4GH server landing page will be available at <http://localhost:80>.
To stop the container run `docker container stop ga4gh-server`.

This image does not contains data, only softwares.
Other images should extend it (`FROM`) adding genomic datatabases (created using `ga4gh_repo` tool provided by this image, see [Official Documentation](http://ga4gh-reference-implementation.readthedocs.io/en/latest/datarepo.html)).
The [Docker image for GA4GH reference server with example data](https://github.com/labbcb/docker-ga4gh-example/) extends this image adding example database (from 1000 Genomes Project data).

``` bash
docker container run --rm --name ga4gh-example -d -p 80:80 welliton/ga4gh-example:0.3.6
```

## Sharing genomic database among containers

Mounting `/data` directory might be useful to allow other containers to access the same database without duplicating data.
For example, run the `ga4gh-server` image (does not contain data) connected at `ga4gh-example` database.
Other example is running GA4GH Beacon server connected at the same database.
For more information see [Docker image for GA4GH Beacon server](https://github.com/labbcb/docker-ga4gh-beacon).

``` bash
docker container run --rm --name ga4gh-example -v ga4gh-example-data:/data:ro -d -p 80:80 welliton/ga4gh-example:0.3.6
```

Explaining the command line: `-v ga4gh-example-data:/data:ro` instructs Docker to mount `/data` directory as read-only (`ro`) at as named volume `ga4gh-example-data`.
Setting directory as read-only avoids problems with concurrency.
Run a second container.

``` bash
docker container run --rm --name ga4gh-server -v ga4gh-example-data:/data -d -p 81:80 welliton/ga4gh-server:0.3.6
```

The second container does not depends on the first one.
Instead, it mounts the `ga4gh-example-data` volume.
Docker volumes are independent of container, we can stop (and remove) the first container.
The second container will still working.
It is even possible to remove the image without losing data in the volume (`docker image rm welliton/ga4gh-example:0.3.6`).
The volume will still available.
To remove a volume all containers connected should be stopped first (in this example `docker stop ga4gh-server`).
Then, run `docker volume rm ga4gh-example-data` to remove the volume (and all its data).
For more information about Docker Volumes see [Manage data in containers](https://docs.docker.com/engine/tutorials/dockervolumes/).

## Buiding this image

``` bash
git clone git@github.com:labbcb/docker-ga4gh-server.git
cd docker-ga4gh-server/
docker build -t welliton/ga4gh-server:0.3.6 .
```

## Related images

- [Docker image for GA4GH reference server with example data](https://github.com/labbcb/docker-ga4gh-example/)
- [Docker image for GA4GH reference server with 1000 Genomes Project data](https://github.com/labbcb/docker-ga4gh-1kgenomes/)
- [Docker image for GA4GHshiny client application](https://github.com/labbcb/docker-ga4gh-shiny/)
- [Docker image for GA4GH Beacon server](https://github.com/labbcb/docker-ga4gh-beacon)
