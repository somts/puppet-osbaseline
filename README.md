# osbaseline

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with osbaseline](#setup)
    * [What osbaseline affects](#what-osbaseline-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with osbaseline](#beginning-with-osbaseline)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module is designed to be called by warious operating systems to get them up to a baseline.  The basic premise is:

* Get package manager and packages installed
* Call any baseline classes to the get OS further inline (e.g. puppet_agent)
* Silently fail when an unsupported OS calls this (e.g. we might not have much to do for say, cumulus linux, but we want a profile class to be able to call this class indisciriminately).

## Setup

### Beginning with osbaseline

## Usage

This module is designed to work well with Hiera. Calling it in Puppet will probably simply be:
```puppet
contain osbaseline
```

## Reference

IN PROGRESS


## Limitations

OSes tested:
* CentOS 7
* Ubuntu 16.04
* FreeBSD 11.1
* Windows 10

## Development

This is presently an in-house module.
