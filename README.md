# instantUPDATE

update application for instantOS


## Ideas

incremental updates. Arch has a tendency to break when not updating for a long
time. Packages and operations are tested only so far as that they don't break on
new installations or actively maintained ones. Installations that are in a state
that nobody has tested in months or years can break when "skipping" intermediate
updates. Keeping old update scripts around and executing them one after another
until the current version is the newest one solves this problem, as the update
script only gets executed on the version it was intended for. 


## TODO: issues

If the update script relies on packages that don't exist anymore, it will fail.  
e.g. pamac-nosnap



