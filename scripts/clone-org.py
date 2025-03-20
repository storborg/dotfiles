#!/usr/bin/env python

import logging
import sys
import os.path
import subprocess
import pprint
import argparse

import coloredlogs
import requests

log = logging.getLogger(__name__)


def get_repo_names(org_name, no_forks=False):
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    url = "https://api.github.com/orgs/%s/repos" % org_name
    log.debug("making github api request: %s", url)
    r = requests.get(url, headers=headers)
    doc = r.json()
    # pprint.pprint(doc)
    for repo in doc:
        repo_name = repo["name"]
        if no_forks and repo["fork"]:
            log.debug("skipping fork: %s", repo_name)
        else:
            yield repo_name


def sync_repo(org_name, repo_name, use_ssh=False):
    log.info("syncing %s", repo_name)
    org_path = org_name

    if not os.path.exists(org_path):
        os.makedirs(org_path)

    repo_path = os.path.join(org_path, repo_name)
    if os.path.exists(repo_path):
        # Do a git pull in it
        log.debug("running git pull in %s", repo_path)
        subprocess.check_call(
            ["git", "pull"],
            cwd=repo_path,
            stdout=sys.stdout,
            stderr=sys.stderr,
        )
    else:
        if use_ssh:
            repo_url = "git@github.com:%s/%s" % (org_name, repo_name)
        else:
            repo_url = "https://github.com/%s/%s" % (org_name, repo_name)
        log.debug("cloning %s in %s", repo_name, org_name)
        subprocess.check_call(
            ["git", "clone", repo_url],
            cwd=org_path,
            stdout=sys.stdout,
            stderr=sys.stderr,
        )


def main(argv=sys.argv):
    p = argparse.ArgumentParser("clone all of an org's repos")
    p.add_argument("--verbose", "-v", action="store_true")
    p.add_argument("--no-forks", action="store_true")
    p.add_argument("--use-ssh", action="store_true")
    p.add_argument("org_name")
    opts = p.parse_args(argv[1:])

    coloredlogs.install(level="DEBUG" if opts.verbose else "INFO")

    org_name = opts.org_name
    log.debug("cloning/syncing all repos for: %s", org_name)
    for repo_name in get_repo_names(org_name, no_forks=opts.no_forks):
        sync_repo(org_name, repo_name, use_ssh=opts.use_ssh)


if __name__ == "__main__":
    main()
