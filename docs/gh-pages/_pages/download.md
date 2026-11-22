---
title: "Download"
permalink: /download/
excerpt: "Download cqfd6 for Debian, Ubuntu, Fedora, Arch Linux, and Windows."
---

<p id="cqfd-os" class="notice--info" hidden></p>

## Linux

Install [Docker Engine], and download the package of your distribution:

<div class="cqfd-grid cqfd-packages">
  <article class="cqfd-card">
    <i class="cqfd-card__icon fab fa-debian" aria-hidden="true"></i>
    <h3>Debian, Ubuntu</h3>
    <p>Debian package<br><code>cqfd6_6_all.deb</code></p>
    <div class="cqfd-card__actions">
      <a class="btn btn--primary btn--small" href="https://github.com/gportay/cqfd6/releases/download/v6/cqfd6_6_all.deb">Download</a>
    </div>
  </article>
  <article class="cqfd-card">
    <i class="cqfd-card__icon fab fa-fedora" aria-hidden="true"></i>
    <h3>Fedora, Red Hat</h3>
    <p>RPM package<br><code>cqfd6-6-1.noarch.rpm</code></p>
    <div class="cqfd-card__actions">
      <a class="btn btn--primary btn--small" href="https://github.com/gportay/cqfd6/releases/download/v6/cqfd6-6-1.noarch.rpm">Download</a>
    </div>
  </article>
  <article class="cqfd-card">
    <i class="cqfd-card__icon fab fa-linux" aria-hidden="true"></i>
    <h3>Arch Linux, Manjaro</h3>
    <p>Arch Linux package<br><code>cqfd6-6-1-any.pkg.tar.zst</code></p>
    <div class="cqfd-card__actions">
      <a class="btn btn--primary btn--small" href="https://github.com/gportay/cqfd6/releases/download/v6/cqfd6-6-1-any.pkg.tar.zst">Download</a>
    </div>
  </article>
  <article class="cqfd-card">
    <i class="cqfd-card__icon fas fa-file-zipper" aria-hidden="true"></i>
    <h3>Other distributions</h3>
    <p>Source archive<br><code>cqfd6-6.tar.gz</code></p>
    <div class="cqfd-card__actions">
      <a class="btn btn--primary btn--small" href="https://github.com/gportay/cqfd6/archive/refs/tags/v6.tar.gz">Download</a>
    </div>
  </article>
</div>

Then, install it from a terminal:

```console
$ sudo apt install ~/Downloads/cqfd6_6_all.deb
$ sudo dnf install ~/Downloads/cqfd6-6-1.noarch.rpm
$ sudo pacman -U ~/Downloads/cqfd6-6-1-any.pkg.tar.zst
```

Or, for other distributions, extract the archive, and install it:

```console
$ tar xf ~/Downloads/cqfd6-6.tar.gz
$ cd cqfd6-6
$ sudo make install
```

## Windows

Install Ubuntu with `wsl --install`, and [Docker Desktop] with **Settings** ›
**Resources** › **WSL integration** turned on. Then, in **Ubuntu**:

```console
$ curl -LO https://github.com/gportay/cqfd6/releases/download/v6/cqfd6_6_all.deb
$ sudo apt install ./cqfd6_6_all.deb
```

[Docker Engine]: https://docs.docker.com/engine/install/
[Docker Desktop]: https://docs.docker.com/desktop/features/wsl/

<script>
  // Propose the section of the visitor's operating system.
  (function () {
    var ua = navigator.userAgent || "";
    var platform = ua + " " + ((navigator.userAgentData &&
                                navigator.userAgentData.platform) ||
                               navigator.platform || "");
    var os;
    if (/android|iphone|ipad|ipod/i.test(ua))
      return;
    if (/win/i.test(platform))
      os = { id: "windows", name: "Windows" };
    else if (/linux|x11|cros/i.test(platform))
      os = { id: "linux", name: "Linux" };
    if (!os || !document.getElementById(os.id))
      return;
    var notice = document.getElementById("cqfd-os");
    notice.innerHTML = 'It looks like you are using ' + os.name +
      '. <a href="#' + os.id + '">Install cqfd6 on ' + os.name + '</a>.';

    // Some browsers tell the Linux distribution in their user agent.
    var distros = [
      { re: /ubuntu/i, name: "Ubuntu", pkg: ".deb" },
      { re: /debian/i, name: "Debian", pkg: ".deb" },
      { re: /fedora/i, name: "Fedora", pkg: ".rpm" },
      { re: /arch linux|manjaro/i, name: "Arch Linux", pkg: ".pkg.tar.zst" }
    ];
    for (var i = 0; os.id === "linux" && i < distros.length; i++) {
      if (!distros[i].re.test(ua))
        continue;
      var link = document.querySelector('.cqfd-packages a[href$="' + distros[i].pkg + '"]');
      if (!link)
        break;
      notice.innerHTML = 'It looks like you are using ' + distros[i].name +
        '. <a href="' + link.href + '">Download ' + link.href.split("/").pop() +
        '</a>, and <a href="#linux">install it</a>.';
      break;
    }
    notice.hidden = false;
  })();
</script>
