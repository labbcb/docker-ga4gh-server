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
docker container run \
  --rm \
  --name ga4gh-server \
  --detach \
  --publish 80:80 \
  welliton/ga4gh-server:0.3.6
```

This image does not have `latest` tag.
It provides a tag for each release of the GA4GH reference server. 
The image version (0.3.6) is based on [release version](https://github.com/ga4gh/ga4gh-server/releases) of the GA4GH reference server.
The GA4GH server landing page will be available at <http://localhost:80>.
To stop the container run `docker container stop ga4gh-server`.

This image does not contains data, only softwares.
Genomic files should be mounted as Docker volume.
The tutorial below shows how to download 1000 Genomics Project data, initialize database and deploy GA4GH server.

Download 1000 Genomes project data

``` bash
wget ftp://ftp.1000genomes.ebi.ac.uk//vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
wget ftp://ftp.1000genomes.ebi.ac.uk//vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.fai
wget ftp://ftp.1000genomes.ebi.ac.uk//vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.gzi
wget https://raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/so-xp-dec.obo
for i in $(seq 1 22); do
  wget "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${i}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz"
  wget "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${i}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz.tbi"
done
```

Init repository

``` bash
docker container run \
  --rm \
  --volume $(pwd):/data:rw \
  welliton/ga4gh-server:v0.3.6 \
  bash -c "ga4gh_repo init --force registry.db && \
    ga4gh_repo add-dataset registry.db 1kgenomes && \
    ga4gh_repo add-referenceset registry.db hs37d5.fa.gz --name GRCh37 && \
    ga4gh_repo add-ontology registry.db so-xp-dec.obo -n so-xp && \
    ga4gh_repo add-variantset registry.db 1kgenomes /data/ \
      --name phase3-release --referenceSetName GRCh37"
```

Deploy server

``` bash
docker container run --detach \
  --name ga4gh-1kgenomes \
  --publish 80:80 \
  --rm \
  --volume $(pwd):/data:ro \
  welliton/ga4gh-server:v0.3.6
```

Stop server

``` bash
docker container stop ga4gh-1kgenomes
```

## Related images

- [Docker image for GA4GHshiny application](https://github.com/labbcb/docker-ga4gh-shiny/)
