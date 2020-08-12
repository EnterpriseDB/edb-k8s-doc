# Tagging policy

## ubi7 / ubi8 images

EDB images are based on a [Red Hat Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image), and are tagged accordingly.
* ubi7 images are based on [Red Hat Universal Base Image version 7](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
* ubi8 images are based on [Red Hat Universal Base Image version 8](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)

## amd64 / ppc64le images

EDB images are built for a specific architecture, and tagged accordingly.
* amd64 images are based on [x86-64](https://en.wikipedia.org/wiki/X86-64) processor architecture
* ppc64le images (future) are based on [PowerPC](https://en.wikipedia.org/wiki/PowerPC) Little Endian processor architecture

## latest images

Every repository also delivers an image tagged with the `latest` tag. This image points to the latest ubi7 / amd64 image of that repository.

# Repositories

## PostgreSQL and EDB Postgres Advanced Server

The PostgreSQL and EDB Postgres Advanced Server images can be acquired from the following repositories:
* https://quay.io/repository/edb/postgresql-10
* https://quay.io/repository/edb/postgresql-11
* https://quay.io/repository/edb/postgresql-12
* https://quay.io/repository/edb/postgres-advanced-server-10
* https://quay.io/repository/edb/postgres-advanced-server-11
* https://quay.io/repository/edb/postgres-advanced-server-12

Each of these repositories have all images built for that specific major version, tagged according to the [Generic tagging policy](#tagging-policy).

## Other image types
Next to Postgres images, EDB also delivers images for other functionalities:
* https://quay.io/repository/operator: Operator images
* https://quay.io/repository/pgxexporter: Prometheus Exporter images
* https://quay.io/repository/stolon: Stolon Sentinel High Availablity images
* https://quay.io/repository/proxy: Stolon Proxy images

Each of these repositories will have all images, tagged according to the [Generic tagging policy](#tagging-policy).
