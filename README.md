# buildbench-js

Do you run your NodeJS frontend locally in Docker?

We got sick of waiting for 2 minute installs every time the package.json changed.

How can we get NPM to install things incrementally, like it does locally?

## Usage

Install Docker and Python3. Run

```
make profile
```

to run a set of incremental docker builds with different build-optimization techniques.

## Methodology

Each benchmark makes a trivial change to package.json (where "trivial" means that
we don't change the dependencies).

- Naked: Run `npm install` without containers
- Naive: Run `npm install` inside Docker
- Buildkit: Run `npm install` inside Docker with Buildkit enabled
- Cachemount: Run `npm install` with /root/.cache mounted as a cache directory, with Buildkit's [experimental build-time mounts](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md).
- Cachedir: Run `npm install`, using /app/node_modules from previous builds as the base of the new build.
- CachedirCopy: Run `npm install`, copying /app/node_modules from previous builds to the new build.
- CachedirBuildkit: Run `npm install`, using /app/node_modules from previous builds as the base of the new build, and using Buildkit.

## Results

When the builds finish, you should get results that look like this:

```
Make naive: 58.278516s
Make buildkit: 56.46206s
Make cachemount: 45.003745s
Make cachedir: 20.155373s
Make cachedircopy: 22.342685s
Make cachedirbuildkit: 14.674813s
Make tailybuild: 14.977888s
Make naked: 21.306247s
```

Numbers may vary based on hardware, operating system, and Docker version.

## License

Copyright 2018 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
