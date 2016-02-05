Installation (Classic)
==============

Given an Arch Linux system, run the following to prepare the JuNest builder:

```sh
curl -k https://raw.githubusercontent.com/fsquillace/junest-builder/master/setup_builder.sh | bash
```

This will create a new user (`builder`) and create the basic packages such as
`droxi` used for publishing the JuNest image to Dropbox.

Create manually the JuNest image
------------

Access as *builder* user:

    # ssh builder@<hostname>
    $ ARCH=<one of x86, x86_64, arm>
    $ git clone https://github.com/fsquillace/junest-builder.git /home/builder
    $ systemctl --user daemon-reload
    $ systemctl --user start junest@${ARCH}.service

To automatically generate the image as soon as the user session is opened:

    $ systemctl --user enable junest@${ARCH}.service

Installation using Digital Ocean
================

With [Digital Ocean](https://cloud.digitalocean.com/droplets)
you can create x32 or x64 JuNest builders.
This procedure suppose you already have a digital ocean account.

Please, follow these steps to create a snapshot for JuNest builder:

- Create a [ssh key](https://cloud.digitalocean.com/settings/security)
    - Store the generated key in your pc in `~/.ssh/digitalocean_rsa`
- Go to 'Create a droplet':
    - Select the options defined [here](https://github.com/gh2o/digitalocean-debian-to-arch)
    - Select the ssh key you have previously created
    - You now have a full ArchLinux droplet ready!
- Install the JuNest builder:
    - Ssh to the droplet:
    `ssh -i ~/.ssh/digitalocean_rsa root@<droplet ip>`
    - Execute the script:
    `curl -k https://raw.githubusercontent.com/fsquillace/junest-builder/master/setup_builder.sh | bash`
    - Access as ***builder*** user: `ssh -i ~/.ssh/digitalocean_rsa builder@<droplet ip>`
    - Provide the droxi access code at the end of the procedure.
      - `droxi`
    - `poweroff` the droplet
- Create a snapshot from the created droplet

You now have the JuNest builder snapshot!

To automate the creation of JuNest images you also need:

- Create an access token from the digital ocean website
- Get the snapshot image id you have previously created:
    `curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer <access token>' "https://api.digitalocean.com/v2/images"`
- Get the ssh key id you have previously created:
    `curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer <access token>' "https://api.digitalocean.com/v2/account/keys"`

Create the JuNest image using Digital Ocean snapshot
----------------------------------

```sh
    ./start_digitalocean.sh <access token> <snapshot id> <ssh key id> <x86 or x86\_64>
```

Installation using Scaleway
================

**Please Note**: This is just a draft at the moment.

With [Scaleway](https://cloud.scaleway.com)
you can create an arm JuNest builder.
This procedure suppose you already have a scaleway account.

Please, follow these steps to create a snapshot for JuNest builder:

- Create a [ssh key](https://cloud.scaleway.com/#/credentials)
    - Store the generated key in your pc in `~/.ssh/scaleway_rsa`
- Go to 'Create a Arch Linux server'
- Install the JuNest builder:
    - Ssh to the server:
    `ssh -i ~/.ssh/scaleway_rsa root@<server ip>`
    - Execute the script:
    `curl -k https://raw.githubusercontent.com/fsquillace/junest-builder/master/setup_builder.sh | bash`
    - Provide the droxi access code at the end of the procedure.
    - `poweroff` the server
- Create an image from the created server
    - Shut down the server (as archive)
    - From the volume, create the snapshot
    - From the snapshot create the image

You now have the JuNest builder image!

To automate the creation of JuNest images you also need:

- Create an access token from the scaleway website
- Get the image id you have previously created from the scaleway website
- Get the organization id:
    `curl -X GET -H "X-Auth-Token: <access token>" https://account.cloud.online.net/organizations`

Create the JuNest image using Scaleway image
----------------------------------

```sh
    ./start_scaleway.sh <access token> <image id> <organization id> <x86 or x86\_64>
```
