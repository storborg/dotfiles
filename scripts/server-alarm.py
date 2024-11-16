import os.path
import subprocess
import urllib
import sys
import time


__here__ = os.path.dirname(__file__)


def play_audio(filename):
    return subprocess.Popen(['afplay %s' % filename],
                            shell=True, stdin=None,
                            stdout=None, stderr=None)


class Failure(Exception):

    def __init__(self, msg):
        self.msg = msg

    def str(self):
        return self.msg


class ServerCheck(object):

    def __init__(self, url, min_size=5000):
        self.url = url
        self.min_size = min_size

    def check_once(self):
        try:
            webf = urllib.urlopen(self.url)
        except Exception as e:
            raise Failure("Failed to connect: %r" % e)

        code = webf.getcode()
        if code != 200:
            raise Failure('Bad HTTP Status code: %d' % code)

        info = webf.info()
        content_type = info.getheader('Content-Type')
        if not content_type.startswith('text/html'):
            raise Failure('Bad Content-Type: %r' % content_type)

        buf = webf.read()
        size = len(buf)
        if size < self.min_size:
            raise Failure('Response too small: got %d bytes' % size)


class Checker(object):

    def __init__(self, interval=10):
        self.checks = []
        self.interval = interval

    def add(self, check):
        self.checks.append(check)

    def check_once(self):
        for check in self.checks:
            try:
                check.check_once()
            except Failure as e:
                self.sound_alarms()
                print "Failure checking %r:" % check.url
                print str(e)

    def sound_alarms(self):
        play_audio(os.path.join(__here__, 'malfunctioning.wav'))

    def run(self):
        while True:
            print "Running checks... "
            self.check_once()
            print "Done"
            time.sleep(self.interval)


if __name__ == '__main__':
    checker = Checker()
    for arg in sys.argv[1:]:
        print "Adding check for %s" % arg
        checker.add(ServerCheck(url=arg))
    checker.run()
