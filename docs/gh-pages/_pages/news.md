---
title: "News"
permalink: /news/
excerpt: "cqfd6 releases and announcements."
---

### cqfd6 gets a <mark>website</mark>

26 November 2026

cqfd6 now has a website! It covers the installation, the getting started, the
use cases, Podman, and more.

### <mark>cqfd6 6</mark> is coming soon

cqfd6 6 is the first release of the fork. It deprecates the former command
line interface in favor of a much simpler one, similar to the one of `sudo`,
adds the `--platform` option and the `platform` property to support
[multi-platform] images, the `tag` and `image` properties to name or pull the
image, and the `--ls` and `--gc` commands to clean up the images. It also
deprecates the `.cqfd` directory, the `distro` and the `custom_img_name`
properties. See the [CHANGELOG][changelog] for details.

[multi-platform]: https://docs.docker.com/build/building/multi-platform/
[changelog]: https://github.com/gportay/cqfd6/blob/master/CHANGELOG.md
