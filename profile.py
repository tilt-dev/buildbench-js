#!/usr/bin/env python

import datetime
import subprocess

def make(cmd: str):
    return_code = subprocess.call(['make', cmd])
    if return_code != 0:
        raise Exception('"make {}" exited with exit code {}'.format(cmd, return_code))

def time_build(cmd: str):
    """
        Run the make command twice, and time the second one, so that we
        get an incremental build timing.
    """
    make(cmd)

    with Timer() as t:
        make(cmd)

    return t.duration_secs

class Timer:
    def __enter__(self):
        self.start = datetime.datetime.now()
        return self

    def __exit__(self, *args):
        self.duration_secs = secs_since(self.start)

def secs_since(t: datetime.datetime) -> float:
    return(datetime.datetime.now() - t).total_seconds()

make('clean')
naive_dur = time_build('naive')
buildkit_dur = time_build('buildkit')
cachemount_dur = time_build('cachemount')
cachedir_dur = time_build('cachedir')
cachedirbuildkit_dur = time_build('cachedirbuildkit')
cachedircopy_dur = time_build('cachedircopy')
cachedircopybuildkit_dur = time_build('cachedircopybuildkit')
tailybuild_dur = time_build('tailybuild')
naked_dur = time_build('naked')
make('clean')

print('\n------------- Results -------------\n')
print('Make naive: {}s'.format(naive_dur))
print('Make buildkit: {}s'.format(buildkit_dur))
print('Make cachemount: {}s'.format(cachemount_dur))
print('Make cachedir: {}s'.format(cachedir_dur))
print('Make cachedirbuildkit: {}s'.format(cachedirbuildkit_dur))
print('Make cachedircopy: {}s'.format(cachedircopy_dur))
print('Make cachedircopybuildkit: {}s'.format(cachedircopybuildkit_dur))
print('Make tailybuild: {}s'.format(tailybuild_dur))
print('Make naked: {}s'.format(naked_dur))
