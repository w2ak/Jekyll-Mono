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
    ap_build = ap_.add_parser('build',help='Jekyll build the website.')
    ap_build.set_defaults(action=manage_build)
    ap_serve = ap_.add_parser('serve',help='Jekyll locally server the website.')
    ap_serve.set_defaults(action=manage_serve)
    return ap.parse_args()

def manage_build(a,c):
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


if __name__=='__main__':
    args = get_args()
    cfg = get_config()
    args.action(args,cfg)
