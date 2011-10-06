import os
import json
import urllib

username = raw_input('Username? ')
api_token = raw_input('API Token? ')
repo = raw_input('Repository name (e.g. storborg/dotfiles)? ')

fname = repo.replace('/', '-') + '-issues.json'
print "Backing up issues to %s..." % fname

class GithubIssues(object):
    api = 'http://github.com/api/v2/json/issues'

    def __init__(self, login, token):
        self.params = urllib.urlencode({'login': login,
                                        'token': token})

    def _get(self, op, repo, *args):
        url = '%s/%s/%s' % (self.api, op, repo)
        if args:
            url += '/' + '/'.join(str(arg) for arg in args)
        return json.load(urllib.urlopen(url, self.params))

    def list(self, repo, state='open'):
        return self._get('list', repo, state)['issues']

    def comments(self, repo, number):
        return self._get('comments', repo, number)['comments']


github = GithubIssues(username, api_token)
issues = github.list(repo, 'open') + github.list(repo, 'closed')

for ii, issue in enumerate(issues):
    print "processing %d/%d" % (ii + 1, len(issues))
    issue['comments'] = github.comments(repo, issue['number'])

f = open(fname, 'w')
json.dump(issues, f, indent=2)
f.close()
