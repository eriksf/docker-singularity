# docker-singularity
Repository for building several different versions of singularity images

## Requirements

* Docker

## Usage

Create test images from various version of singularity

```
make test_images
```

Tar them up for transfer to test system and then remove docker images

```
tar -czf test_images.tar.gz *simg
make clean
```
