"""
Run me like 'python paranoia.py'.

I'll mark every cert in the System Keychain as explicitly untrusted for all
types of use. This is better than deleting certs, because you can manually
decide if you want to trust the CA later, and still get the benefit of verifying
the issuer.
"""

from subprocess import call
from tempfile import NamedTemporaryFile
from plistlib import readPlist, writePlist, Data
from datetime import datetime


def export_trust(level):
    """
    Call the `security` tool to get a plist of trust settings for the given
    level (admin | system | user).
    """
    flag = {'admin': '-d',
            'user': '',
            'system': '-s'}[level]
    tf = NamedTemporaryFile()
    ret = call(['/usr/bin/security',
                'trust-settings-export',
                flag,
                tf.name])
    if ret > 0:
        raise OSError("exporting %s trust failed, exit code %d" %
                      (level, ret))

    return readPlist(tf.name)


def import_trust(level, pl):
    """
    Call the `security` tool to import a plist of trust settings for the given
    level (admin | user).
    """
    flag = {'admin': '-d',
            'user': ''}[level]
    tf = NamedTemporaryFile()
    writePlist(pl, tf.name)
    ret = call(['/usr/bin/security',
                'trust-settings-import',
                flag,
                tf.name])
    if ret > 0:
        raise OSError("imported %s trust failed, exit code %d" %
                      (level, ret))


def tags_to_untrust_all():
    return [
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x03'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147408896,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x03'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x08'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147408872,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x08'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\t'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x0b'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x0c'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x0e'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x0f'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x10'),
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsResult': 3
        },
        {
            'kSecTrustSettingsAllowedError': -2147409654,
            'kSecTrustSettingsPolicy': Data('*\x86H\x86\xf7cd\x01\x02'),
            'kSecTrustSettingsResult': 3
        }]


def untrust_all(pl):
    for cert_info in pl['trustList'].itervalues():
        untrust_cert(cert_info)


def untrust_prompt(pk):
    for cert_info in pl['trustList'].itervalues():
        name = cert_info['issuerName'].data.decode('ascii', 'replace')
        name = name.replace('?', '')
        name = ' '.join(name.split())
        print name
        yn = raw_input('Trust? [y/N] ')
        if yn.startswith('y'):
            print "Trusting."
        else:
            print "Not trusting."
            untrust_cert(cert_info)


def untrust_cert(cert_info):
    cert_info['modDate'] = datetime.utcnow()
    cert_info['trustSettings'] = tags_to_untrust_all()


if __name__ == '__main__':
    print "Exporting system trust settings..."
    pl = export_trust('system')
    print "Adding deny entries for all certs..."
    untrust_prompt(pl)
    print "Import admin trust settings..."
    import_trust('admin', pl)
