# buildbench-js

Do you run your NodeJS frontend locally in Docker?

We got sick of waiting for 2 minute installs every time the package.json changed.

How can we get Yarn to install things incrementally, like it does locally?

## Usage

Install Docker and Python3. Run

```
make profile
```

to run a set of incremental docker builds with different build-optimization techniques.

## Methodology

Each benchmark makes a trivial change to package.json (where "trivial" means that
we don't change the dependencies).

- Naked: Run `yarn install` without containers
- Naive: Run `yarn install` inside Docker
- Buildkit: Run `yarn install` inside Docker with Buildkit enabled
- Cachemount: Run `yarn install` with /root/.cache mounted as a cache directory, with Buildkit's [experimental build-time mounts](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md).
- Cachedir: Run `yarn install`, using /app/node_modules from previous builds as the base of the new build.
- CachedirCopy: Run `yarn install`, copying /app/node_modules from previous builds to the new build.
- CachedirBuildkit: Run `yarn install`, using /app/node_modules from previous builds as the base of the new build, and using Buildkit.

## Results

When the builds finish, you should get results that look like this:

```
Make naive: 66.698035s
Make buildkit: 49.008923s
Make cachemount: 51.606757s
Make cachedir: 8.262599s
Make cachedirbuildkit: 3.940743s
Make cachedircopy: 8.391028s
Make cachedircopybuildkit: 3.783343s
Make tailybuild: 2.030925s
Make naked: 2.673993s
```

Numbers may vary based on hardware, operating system, and Docker version.

## License

Copyright 2018 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
