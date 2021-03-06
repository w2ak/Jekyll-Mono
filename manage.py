#!/usr/bin/env python3
import argparse,os,yaml,subprocess

class Bunch(object):
    def __init__(self,adict,safe=True):
        if safe:
            adict = dict(adict)
        for x in adict:
            if isinstance(adict[x],dict):
                adict[x] = Bunch(adict[x],safe=False)
        self.__dict__.update(adict)

def get_config():
    path = os.path.dirname(__file__)
    cfg = os.path.join(path,'_site.yml')
    with open(cfg,'r') as f:
        cfg = yaml.load(f)
    return Bunch(cfg)

def get_args():
    ap = argparse.ArgumentParser(description='Manage blog.')
    ap_ = ap.add_subparsers(help='SubCommand', metavar='cmd')
    ap_.required = True
    ap_.dest = 'cmd'
    ap_build = ap_.add_parser('build',help='Jekyll build the local website.')
    ap_build.set_defaults(action=manage_build)
    ap_update = ap_.add_parser('update',help='Jekyll update the remote website.')
    ap_update.set_defaults(action=manage_update)
    ap_serve = ap_.add_parser('serve',help='Jekyll locally server the website.')
    ap_serve.set_defaults(action=manage_serve)
    ap_tar = ap_.add_parser('tar',help='Build and archive the build folder.')
    ap_tar.set_defaults(action=manage_tar)
    ap_gpg = ap_.add_parser('gpg',help='Update gpg key.')
    ap_gpg.set_defaults(action=manage_gpg)
    return ap.parse_args()

def manage_build(a,c):
    toexec = [ 'jekyll', 'build' ]
    result = subprocess.run(toexec)
    result.check_returncode()
    return

def manage_update(a,c):
    server = '{:}@{:}'.format(cfg.remote.user,cfg.remote.address)
    command = 'cd "{:}" && git pull "{:}" "{:}" && jekyll build'\
            .format(cfg.remote.dir,cfg.remote.remote,cfg.remote.branch)
    toexec = [ 'ssh', server, command ]
    result = subprocess.run(toexec)
    result.check_returncode()
    return

def manage_serve(a,c):
    toexec = [ 'screen', '-S', 'jekyll', '-d', '-m', 'jekyll', 'serve', '--incremental' ]
    result = subprocess.run(toexec)
    result.check_returncode()
    return

def manage_tar(a,c):
    manage_build(a,c)
    toexec = [ 'tar', '-C', '_site', '-c', '-z', '-f', 'www.tar.gz', '.' ]
    result = subprocess.run(toexec)
    result.check_returncode()
    return

def manage_gpg(a,c):
    env = os.environ.copy()
    try:
        gpgbin = c.gpg.bin
    except AttributeError:
        gpgbin = 'gpg2'
    gpgkey = c.gpg.key
    gpgfile = c.gpg.file
    mktemp = [ 'mktemp', '-d' ]
    tempdir = subprocess.check_output(mktemp).decode('utf-8').strip()
    chmod = [ 'chmod', '700', tempdir ]
    subprocess.run(chmod).check_returncode()
    clean = [ 'find', tempdir, '-mindepth', '1', '-delete' ]
    subprocess.run(clean).check_returncode()
    env["GNUPGHOME"] = tempdir
    recv = [ gpgbin, '--recv-key', gpgkey ]
    subprocess.run(recv, env=env).check_returncode()
    export = [ gpgbin, '--armor', '-o', gpgfile, '--export', gpgkey ]
    subprocess.run(export, env=env).check_returncode()
    clean = [ 'rm', '-rf', tempdir ]
    subprocess.run(clean).check_returncode()

if __name__=='__main__':
    args = get_args()
    cfg = get_config()
    args.action(args,cfg)
